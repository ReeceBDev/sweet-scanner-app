import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sweet_scanner_app/app/scanner_route_arguments.dart';
import 'package:sweet_scanner_app/app/scanner_routes.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/state/library/library_controller.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// The library: a mega list of every named entry. Pressing an entry opens
/// its document screen.
///
/// The page is pure composition and navigation: the listing lives in
/// [LibraryController].
class LibraryPage extends StatefulWidget {
  /// Creates the library page.
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final LibraryController _library;

  @override
  void initState() {
    super.initState();
    _library = LibraryController(
      repository:
          Provider.of<ScanDocumentRepository>(context, listen: false),
    )
      ..addListener(_handleLibraryChanged)
      ..refresh();
  }

  @override
  void dispose() {
    _library.removeListener(_handleLibraryChanged);
    _library.dispose();
    super.dispose();
  }

  void _handleLibraryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openDocument(ScanDocument document) async {
    await Navigator.of(context).pushNamed(
      ScannerRoutes.document,
      arguments: DocumentRouteArgs(documentId: document.id),
    );
    // The document may have been renamed or edited while it was open.
    if (mounted) {
      _library.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: switch (_library.phase) {
        LibraryPhase.ready => _buildList(),
        LibraryPhase.failed => _buildFailed(),
        LibraryPhase.loading =>
          const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildList() {
    final List<ScanDocument> documents = _library.documents;
    if (documents.isEmpty) {
      return const Center(child: Text('No documents yet. Take some photos.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        final ScanDocument document = documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
          child: InkWell(
            onTap: () => _openDocument(document),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.spaceM),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.ink,
                  width: AppSizes.borderWidth,
                ),
                borderRadius:
                    BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      document.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.entry,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Text(
                    '${document.entries.length} '
                    '${document.entries.length == 1 ? 'photo' : 'photos'}',
                    style: const TextStyle(
                      fontSize: AppFontSizes.label,
                      color: AppColors.disabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFailed() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('The library could not be loaded.'),
          const SizedBox(height: AppSizes.spaceM),
          OutlinedButton(
            onPressed: _library.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
