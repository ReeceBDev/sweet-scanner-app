import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// Circular bordered wireframe icon button.
class ScannerIconButton extends StatelessWidget {
  /// Creates the button; [onPressed] may be null to disable it.
  const ScannerIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: AppColors.background,
      shape: CircleBorder(
        side: BorderSide(
          color: AppColors.ink,
          width: AppSizes.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceS),
          child: Icon(
            icon,
            size: AppSizes.iconSize,
            color: AppColors.ink,
          ),
        ),
      ),
    );
    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}
