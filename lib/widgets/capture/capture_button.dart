import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// The shutter: a large circular bordered button.
class CaptureButton extends StatelessWidget {
  /// Creates the shutter; [onCapture] may be null to disable it.
  const CaptureButton({super.key, this.onCapture});

  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: CircleBorder(
        side: BorderSide(color: AppColors.ink, width: AppSizes.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onCapture,
        child: SizedBox(
          width: AppSizes.shutterSize,
          height: AppSizes.shutterSize,
          child: Center(
            child: Container(
              width: AppSizes.shutterInnerSize,
              height: AppSizes.shutterInnerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.ink,
                  width: AppSizes.shutterRingWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
