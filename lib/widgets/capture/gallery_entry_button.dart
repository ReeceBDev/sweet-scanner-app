import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// The gallery shortcut: icon button with a count badge of photos taken.
class GalleryEntryButton extends StatelessWidget {
  /// Creates the button; [count] is the number of photos in the session.
  const GalleryEntryButton({super.key, required this.count, this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        ScannerIconButton(icon: Icons.photo_library, onPressed: onPressed),
        if (count > 0)
          Positioned(
            right: -AppSizes.spaceXs,
            top: -AppSizes.spaceXs,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.spaceXs),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.ink,
                  width: AppSizes.borderWidth,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: AppSizes.badgeMinSize,
                minHeight: AppSizes.badgeMinSize,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(fontSize: AppFontSizes.label),
              ),
            ),
          ),
      ],
    );
  }
}
