import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sweet_scanner_app/data/ocr/text_recognition_gateway.dart';
import 'package:sweet_scanner_app/data/photos/photo_file_store.dart';
import 'package:sweet_scanner_app/state/capture/captured_photo.dart';
import 'package:sweet_scanner_app/state/capture/capture_phase.dart';
import 'package:sweet_scanner_app/state/capture/ocr_status.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';

/// Owns the camera session: the camera lifecycle, the captured photo list and
/// the per-photo OCR pipeline.
///
/// The camera page renders this state through standalone widgets; it never
/// touches the camera plugin or the recogniser directly.
final class CaptureSessionController extends ChangeNotifier {
  /// Creates the controller; call [initialize] once after construction.
  CaptureSessionController({
    required TextRecognitionGateway gateway,
    required PhotoFileStore photoStore,
  }) : _gateway = gateway,
       _photoStore = photoStore;

  final TextRecognitionGateway _gateway;
  final PhotoFileStore _photoStore;

  CameraController? _camera;
  CapturePhase _phase = CapturePhase.idle;
  String? _errorMessage;
  final List<CapturedPhoto> _photos = <CapturedPhoto>[];
  final Map<String, Future<void>> _recognitionRuns = <String, Future<void>>{};
  int _sequence = 0;

  /// The current phase of the camera session.
  CapturePhase get phase => _phase;

  /// The live camera session, or null while the camera is unavailable.
  CameraController? get camera => _camera;

  /// The failure message when the camera could not be prepared, if any.
  String? get errorMessage => _errorMessage;

  /// The photos captured in this session, in capture order.
  List<CapturedPhoto> get photos => List<CapturedPhoto>.unmodifiable(_photos);

  /// Whether at least one photo has been taken (gates the Finished button).
  bool get hasPhotos => _photos.isNotEmpty;

  /// Prepares the camera session, requesting camera access.
  ///
  /// Microphone access is deliberately not requested: photos are stills only.
  Future<void> initialize() async {
    if (_phase == CapturePhase.ready || _phase == CapturePhase.initializing) {
      return;
    }
    _phase = CapturePhase.initializing;
    _errorMessage = null;
    notifyListeners();

    final Map<Permission, PermissionStatus> statuses = await <Permission>[
      Permission.camera,
    ].request();
    final bool accessGranted = statuses[Permission.camera]?.isGranted ?? false;
    if (!accessGranted) {
      _phase = CapturePhase.permissionDenied;
      notifyListeners();
      return;
    }

    try {
      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription lens = cameras.firstWhere(
        (CameraDescription camera) =>
            camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controller = CameraController(
        lens,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      _camera = controller;
      _phase = CapturePhase.ready;
    } on CameraException catch (error) {
      _errorMessage = error.description ?? 'The camera could not be started.';
      _phase = CapturePhase.failed;
    }
    notifyListeners();
  }

  /// Captures a still photo into the session and starts its OCR.
  Future<void> capture() async {
    final CapturedPhoto? photo = await _takePhoto();
    if (photo == null) {
      return;
    }
    _photos.add(photo);
    notifyListeners();
    _startRecognition(photo);
  }

  /// Retakes the photo with [photoId]: a fresh capture replaces it and its
  /// recognition restarts.
  Future<void> retake(String photoId) async {
    final int index = _indexWhere(photoId);
    if (index < 0) {
      return;
    }
    final CapturedPhoto? replacement = await _takePhoto();
    if (replacement == null) {
      return;
    }
    final CapturedPhoto replaced = _photos[index];
    _photos[index] = replacement;
    notifyListeners();
    unawaited(_photoStore.delete(replaced.path));
    _startRecognition(replacement);
  }

  /// Removes the photo with [photoId] from the session and deletes its file.
  void delete(String photoId) {
    final int index = _indexWhere(photoId);
    if (index < 0) {
      return;
    }
    final CapturedPhoto removed = _photos.removeAt(index);
    notifyListeners();
    unawaited(_photoStore.delete(removed.path));
  }

  /// Recognition for [photoId]: awaits the run in flight, restarts a failed
  /// one, or completes immediately. This is the press-to-trigger guarantee —
  /// pressing a photo whose recognition has not completed fetches its text.
  Future<void> ensureRecognition(String photoId) {
    final CapturedPhoto? photo = _photoWhere(photoId);
    if (photo == null) {
      return Future<void>.value();
    }
    final Future<void>? run = _recognitionRuns[photoId];
    if (run != null) {
      return run;
    }
    if (photo.status == OcrStatus.failed) {
      _startRecognition(photo);
      return _recognitionRuns[photoId]!;
    }
    return Future<void>.value();
  }

  /// Awaits every photo's recognition and hands back the document entries
  /// snapshot (photo path + final text). Used when finishing the session.
  Future<List<DocumentEntry>> snapshotEntries() async {
    await Future.wait(<Future<void>>[
      for (final CapturedPhoto photo in _photos)
        _recognitionRuns[photo.id] ?? Future<void>.value(),
    ]);
    return <DocumentEntry>[
      for (final CapturedPhoto photo in _photos)
        DocumentEntry(
          id: 'entry-${photo.id}',
          photoPath: photo.path,
          text: photo.text,
        ),
    ];
  }

  /// Clears the session while keeping every photo file: the photos have been
  /// handed over to a document.
  void consume() {
    if (_photos.isEmpty) {
      return;
    }
    _photos.clear();
    notifyListeners();
  }

  /// Discards the session and deletes every photo file (abandoning work).
  Future<void> discard() async {
    if (_photos.isEmpty) {
      return;
    }
    final List<CapturedPhoto> removed = List<CapturedPhoto>.of(_photos);
    _photos.clear();
    notifyListeners();
    for (final CapturedPhoto photo in removed) {
      await _photoStore.delete(photo.path);
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<CapturedPhoto?> _takePhoto() async {
    final CameraController? camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return null;
    }
    try {
      final XFile shot = await camera.takePicture();
      final String path = await _photoStore.saveCapture(
        await shot.readAsBytes(),
      );
      _sequence += 1;
      return CapturedPhoto(id: 'photo-$_sequence', path: path);
    } on CameraException {
      return null;
    }
  }

  void _startRecognition(CapturedPhoto photo) {
    if (_recognitionRuns.containsKey(photo.id)) {
      return;
    }
    _recognitionRuns[photo.id] = _runRecognition(photo.id, photo.path);
  }

  Future<void> _runRecognition(String photoId, String path) async {
    try {
      final String text = await _gateway.recognize(path);
      _updatePhoto(photoId, (CapturedPhoto photo) {
        return photo.copyWith(status: OcrStatus.done, text: text);
      });
    } on TextRecognitionException {
      _updatePhoto(photoId, (CapturedPhoto photo) {
        return photo.copyWith(status: OcrStatus.failed);
      });
    } finally {
      _recognitionRuns.remove(photoId);
    }
  }

  void _updatePhoto(
    String photoId,
    CapturedPhoto Function(CapturedPhoto photo) transform,
  ) {
    final int index = _indexWhere(photoId);
    if (index < 0) {
      return;
    }
    _photos[index] = transform(_photos[index]);
    notifyListeners();
  }

  int _indexWhere(String photoId) =>
      _photos.indexWhere((CapturedPhoto photo) => photo.id == photoId);

  CapturedPhoto? _photoWhere(String photoId) {
    for (final CapturedPhoto photo in _photos) {
      if (photo.id == photoId) {
        return photo;
      }
    }
    return null;
  }
}
