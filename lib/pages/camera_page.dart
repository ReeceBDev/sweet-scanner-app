import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sweet_scanner_app/app/scanner_route_arguments.dart';
import 'package:sweet_scanner_app/app/scanner_routes.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/data/ocr/text_recognition_gateway.dart';
import 'package:sweet_scanner_app/data/photos/photo_file_store.dart';
import 'package:sweet_scanner_app/state/capture/capture_phase.dart';
import 'package:sweet_scanner_app/state/capture/capture_session_controller.dart';
import 'package:sweet_scanner_app/state/capture/captured_photo.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/capture/camera_preview_view.dart';
import 'package:sweet_scanner_app/widgets/capture/capture_button.dart';
import 'package:sweet_scanner_app/widgets/capture/gallery_entry_button.dart';
import 'package:sweet_scanner_app/widgets/common/confirm_popup.dart';
import 'package:sweet_scanner_app/widgets/common/text_prompt_popup.dart';
import 'package:sweet_scanner_app/widgets/gallery/gallery_sheet.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// The app's first screen: a live camera that captures photos, scans each one
/// into text with the phone's built-in OCR, and hands the finished session
/// over to a named document.
///
/// The page is pure composition and navigation: the session lives in
/// [CaptureSessionController], popups are shared widgets, and every visual
/// element is a standalone widget.
class CameraPage extends StatefulWidget {
  /// Creates the camera page.
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late final CaptureSessionController _session;
  bool _galleryOpen = false;

  @override
  void initState() {
    super.initState();
    _session =
        CaptureSessionController(
            gateway: Provider.of<TextRecognitionGateway>(
              context,
              listen: false,
            ),
            photoStore: Provider.of<PhotoFileStore>(context, listen: false),
          )
          ..addListener(_handleSessionChanged)
          ..initialize();
  }

  @override
  void dispose() {
    _session.removeListener(_handleSessionChanged);
    _session.dispose();
    super.dispose();
  }

  void _handleSessionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmAbandon() async {
    final bool confirmed = await ConfirmPopup.confirm(
      context,
      title: 'Abandon work?',
      message: 'Photos taken this session will be lost.',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _session.discard();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      ScannerRoutes.library,
      (Route<void> route) => false,
    );
  }

  Future<void> _finish() async {
    if (!_session.hasPhotos) {
      return;
    }
    final String? name = await TextPromptPopup.prompt(
      context,
      title: 'Name document',
    );
    if (name == null || !mounted) {
      return;
    }
    final ScanDocumentRepository repository =
        Provider.of<ScanDocumentRepository>(context, listen: false);
    final List<DocumentEntry> entries = await _session.snapshotEntries();
    final ScanDocument document = await repository.create(
      name: name,
      entries: entries,
    );
    if (!mounted) {
      return;
    }
    _session.consume();
    await Navigator.of(context).pushNamed(
      ScannerRoutes.document,
      arguments: DocumentRouteArgs(documentId: document.id),
    );
  }

  Future<void> _deletePhoto(CapturedPhoto photo) async {
    final bool confirmed = await ConfirmPopup.confirm(
      context,
      title: 'Delete photo?',
      message: 'This photo and its text will be removed.',
    );
    if (confirmed) {
      _session.delete(photo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_session.phase) {
        CapturePhase.ready => _buildCamera(),
        CapturePhase.permissionDenied => _buildMessage(
          message: 'Camera access is required to scan pages.',
          actionLabel: 'Grant access',
          onAction: _session.initialize,
        ),
        CapturePhase.failed => _buildMessage(
          message: _session.errorMessage ?? 'The camera could not be started.',
          actionLabel: 'Retry',
          onAction: _session.initialize,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildCamera() {
    final CameraController? camera = _session.camera;
    return Stack(
      children: <Widget>[
        if (camera != null)
          Positioned.fill(child: CameraPreviewView(controller: camera))
        else
          const ColoredBox(color: AppColors.background),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceM),
              child: ScannerIconButton(
                icon: Icons.home,
                tooltip: 'Home',
                onPressed: _confirmAbandon,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spaceL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GalleryEntryButton(
                    count: _session.photos.length,
                    onPressed: () => setState(() {
                      _galleryOpen = true;
                    }),
                  ),
                  CaptureButton(onCapture: _session.capture),
                  SizedBox(
                    width: AppSizes.buttonHeight,
                    child: _session.hasPhotos
                        ? OutlinedButton(
                            onPressed: _finish,
                            child: const Text('Finished'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_galleryOpen)
          Positioned.fill(
            child: GallerySheet(
              photos: _session.photos,
              onClose: () => setState(() {
                _galleryOpen = false;
              }),
              onPhotoDelete: _deletePhoto,
              onPhotoRetake: (CapturedPhoto photo) => _session.retake(photo.id),
              onOcrRetry: (CapturedPhoto photo) =>
                  unawaited(_session.ensureRecognition(photo.id)),
            ),
          ),
      ],
    );
  }

  Widget _buildMessage({
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spaceM),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
