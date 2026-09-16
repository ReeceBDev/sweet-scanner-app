import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fills its area with the live camera preview.
class CameraPreviewView extends StatelessWidget {
  /// Creates the preview for [controller].
  const CameraPreviewView({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: CameraPreview(controller));
  }
}
