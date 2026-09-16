import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/capture/ocr_status.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// The expand-upable OCR text box shown underneath a photo. Collapsed it
/// shows the recognition state (or a text snippet); expanded it grows upward
/// to reveal the full recognised text. Tapping a failed scan retries it
/// through [onRetry].
class ExpandableTextBox extends StatefulWidget {
  /// Creates the text box.
  const ExpandableTextBox({
    super.key,
    required this.text,
    required this.status,
    this.onRetry,
  });

  final String text;
  final OcrStatus status;
  final VoidCallback? onRetry;

  @override
  State<ExpandableTextBox> createState() => _ExpandableTextBoxState();
}

class _ExpandableTextBoxState extends State<ExpandableTextBox> {
  bool _expanded = false;

  void _handleTap() {
    if (widget.status == OcrStatus.failed) {
      widget.onRetry?.call();
      return;
    }
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.bottomLeft,
        child: InkWell(
          onTap: _handleTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.spaceM),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.ink,
                  width: AppSizes.borderWidth,
                ),
              ),
            ),
            constraints: _expanded
                ? const BoxConstraints(
                    maxHeight: AppSizes.expandedTextMaxHeight,
                  )
                : null,
            child: _expanded ? _buildExpandedBody() : _buildCollapsedBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedBody() {
    return Row(
      children: <Widget>[
        const Text(
          'OCR text',
          style: TextStyle(
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSizes.spaceS),
        Expanded(child: _buildStatusOrSnippet(singleLine: true)),
        Icon(
          Icons.expand_more,
          size: AppSizes.iconSize,
          color: AppColors.ink,
        ),
      ],
    );
  }

  Widget _buildExpandedBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'OCR text',
                style: TextStyle(
                  fontSize: AppFontSizes.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.expand_less,
                size: AppSizes.iconSize,
                color: AppColors.ink,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          _buildStatusOrSnippet(singleLine: false),
        ],
      ),
    );
  }

  Widget _buildStatusOrSnippet({required bool singleLine}) {
    switch (widget.status) {
      case OcrStatus.running:
        return const Text(
          'Scanning…',
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.disabled,
          ),
        );
      case OcrStatus.failed:
        return const Text(
          'Scan failed — tap to retry',
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.disabled,
          ),
        );
      case OcrStatus.done:
        return Text(
          widget.text.isEmpty ? '(no text)' : widget.text,
          maxLines: singleLine ? 1 : null,
          overflow: singleLine ? TextOverflow.ellipsis : null,
          style: const TextStyle(fontSize: AppFontSizes.body),
        );
    }
  }
}
