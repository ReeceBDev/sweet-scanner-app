import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sweet_scanner_app/app/scanner_routes.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/data/photos/photo_file_store.dart';
import 'package:sweet_scanner_app/state/capture/captured_photo.dart';
import 'package:sweet_scanner_app/state/capture/ocr_status.dart';
import 'package:sweet_scanner_app/state/document/document_editor_controller.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/common/confirm_popup.dart';
import 'package:sweet_scanner_app/widgets/common/text_prompt_popup.dart';
import 'package:sweet_scanner_app/widgets/document/export_action_bar.dart';
import 'package:sweet_scanner_app/widgets/document/merged_text_view.dart';
import 'package:sweet_scanner_app/widgets/document/text_list.dart';
import 'package:sweet_scanner_app/widgets/gallery/gallery_sheet.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// The per-document screen: the document's title (renamable via the pen
/// icon), the text-list widget of its entries, the export view, the gallery
/// shortcut and the camera shortcut.
///
/// The page is pure composition and navigation: edits live in
/// [DocumentEditorController], popups are shared widgets and every visual
/// element is a standalone widget.
class DocumentPage extends StatefulWidget {
  /// Creates the page for the document with [documentId].
  const DocumentPage({super.key, required this.documentId});

  final String documentId;

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late final DocumentEditorController _editor;
  late final PhotoFileStore _photoStore;
  final GlobalKey _exportBoundaryKey = GlobalKey();
  bool _galleryOpen = false;
  bool _exportOpen = false;

  @override
  void initState() {
    super.initState();
    _editor =
        DocumentEditorController(
            repository: Provider.of<ScanDocumentRepository>(
              context,
              listen: false,
            ),
          )
          ..addListener(_handleEditorChanged)
          ..load(widget.documentId);
    _photoStore = Provider.of<PhotoFileStore>(context, listen: false);
  }

  @override
  void dispose() {
    _editor.removeListener(_handleEditorChanged);
    _editor.dispose();
    super.dispose();
  }

  void _handleEditorChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _rename() async {
    final ScanDocument? document = _editor.document;
    if (document == null) {
      return;
    }
    final String? name = await TextPromptPopup.prompt(
      context,
      title: 'Rename document',
      initialText: document.name,
    );
    if (name == null) {
      return;
    }
    await _editor.rename(name);
  }

  Future<void> _deleteEntry(DocumentEntry entry) {
    return _deleteEntryById(entry.id);
  }

  Future<void> _deleteEntryById(String entryId) async {
    final DocumentEntry? entry = _editor.entries
        .where((DocumentEntry entry) => entry.id == entryId)
        .firstOrNull;
    final bool confirmed = await ConfirmPopup.confirm(
      context,
      title: 'Delete entry?',
      message: 'This photo and its text will be removed from the document.',
    );
    if (!confirmed) {
      return;
    }
    await _editor.deleteEntry(entryId);
    if (entry != null) {
      unawaited(_photoStore.delete(entry.photoPath));
    }
  }

  void _openCamera() {
    Navigator.of(context).pushNamed(ScannerRoutes.camera);
  }

  void _done() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      ScannerRoutes.library,
      (Route<void> route) => false,
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _editor.mergedText));
    if (mounted) {
      _showSnack('Copied to clipboard.');
    }
  }

  /// Captures the merged text view as PNG bytes.
  Future<Uint8List?> _captureMergedText() async {
    final BuildContext? boundaryContext = _exportBoundaryKey.currentContext;
    if (boundaryContext == null) {
      return null;
    }
    final RenderRepaintBoundary boundary =
        boundaryContext.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(
      pixelRatio: AppSizes.exportPixelRatio,
    );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _saveAsImage() async {
    final Uint8List? bytes = await _captureMergedText();
    if (bytes == null || !mounted) {
      return;
    }
    final String path = await _photoStore.savePng(bytes);
    if (!mounted) {
      return;
    }
    _showSnack('Saved image: $path');
  }

  Future<void> _shareAsImage() async {
    final Uint8List? bytes = await _captureMergedText();
    if (bytes == null || !mounted) {
      return;
    }
    final String path = await _photoStore.savePng(bytes);
    if (!mounted) {
      return;
    }
    unawaited(
      SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(path)], text: _editor.document?.name),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return switch (_editor.phase) {
      DocumentLoadPhase.ready => _buildReady(),
      DocumentLoadPhase.notFound => const Center(
        child: Text('Document not found.'),
      ),
      DocumentLoadPhase.loading => const Center(
        child: CircularProgressIndicator(),
      ),
    };
  }

  Widget _buildReady() {
    final ScanDocument? document = _editor.document;
    if (document == null) {
      return const Center(child: Text('Document not found.'));
    }
    return Scaffold(
      floatingActionButton: _exportOpen
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() {
                _exportOpen = true;
              }),
              label: const Text('Submit'),
            ),
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                _buildTitleBar(document),
                Expanded(
                  child: _exportOpen
                      ? MergedTextView(
                          entries: _editor.entries,
                          boundaryKey: _exportBoundaryKey,
                        )
                      : TextList(
                          entries: _editor.entries,
                          onEntryDelete: _deleteEntry,
                        ),
                ),
                if (_exportOpen)
                  ExportActionBar(
                    onCopy: _copy,
                    onSave: _saveAsImage,
                    onShare: _shareAsImage,
                  ),
              ],
            ),
          ),
          if (_galleryOpen)
            Positioned.fill(
              child: GallerySheet(
                photos: <CapturedPhoto>[
                  for (final DocumentEntry entry in _editor.entries)
                    CapturedPhoto(
                      id: entry.id,
                      path: entry.photoPath,
                      text: entry.text,
                      status: OcrStatus.done,
                    ),
                ],
                onClose: () => setState(() {
                  _galleryOpen = false;
                }),
                onPhotoDelete: (CapturedPhoto photo) =>
                    _deleteEntryById(photo.id),
                onOcrRetry: (CapturedPhoto photo) {},
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(ScanDocument document) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceM,
            vertical: AppSizes.spaceS,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ScannerIconButton(
                icon: Icons.edit,
                tooltip: 'Rename',
                onPressed: _rename,
              ),
            ],
          ),
        ),
        const Divider(
          height: AppSizes.borderWidth,
          thickness: AppSizes.borderWidth,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.ink, width: AppSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.buttonHeight,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: AppSizes.spaceM),
                child: ScannerIconButton(
                  icon: Icons.photo_library,
                  tooltip: 'Gallery',
                  onPressed: () => setState(() {
                    _galleryOpen = true;
                  }),
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              ScannerIconButton(
                icon: Icons.camera_alt,
                tooltip: 'Camera',
                onPressed: _openCamera,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: AppSizes.spaceM),
                child: OutlinedButton(
                  onPressed: _done,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
