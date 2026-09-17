import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/capture/captured_photo.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/gallery/gallery_photo_card.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// Full-height gallery overlay listing every photo, newest first. Rendered as
/// an in-page overlay so it rebuilds live with the photo list.
class GallerySheet extends StatelessWidget {
  /// Creates the overlay. [onPhotoDelete] / [onPhotoRetake] may be null to
  /// hide the corresponding icons.
  const GallerySheet({
    super.key,
    required this.photos,
    required this.onClose,
    required this.onOcrRetry,
    this.onPhotoDelete,
    this.onPhotoRetake,
  });

  final List<CapturedPhoto> photos;
  final VoidCallback onClose;
  final void Function(CapturedPhoto photo) onOcrRetry;
  final void Function(CapturedPhoto photo)? onPhotoDelete;
  final void Function(CapturedPhoto photo)? onPhotoRetake;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceM),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ScannerIconButton(icon: Icons.close, onPressed: onClose),
                ],
              ),
            ),
            Expanded(
              child: photos.isEmpty
                  ? const Center(child: Text('No photos yet'))
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(AppSizes.spaceM),
                      itemCount: photos.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CapturedPhoto photo = photos[index];
                        return GalleryPhotoCard(
                          photo: photo,
                          onOcrRetry: () => onOcrRetry(photo),
                          onDelete: onPhotoDelete == null
                              ? null
                              : () => onPhotoDelete!(photo),
                          onRetake: onPhotoRetake == null
                              ? null
                              : () => onPhotoRetake!(photo),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
