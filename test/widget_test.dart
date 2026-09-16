import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sweet_scanner_app/data/documents/scan_document_dto.dart';
import 'package:sweet_scanner_app/state/capture/ocr_status.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/theme.dart';
import 'package:sweet_scanner_app/widgets/common/expandable_text_box.dart';

void main() {
  test('scan document DTO round-trips through JSON', () {
    const ScanDocumentDto dto = ScanDocumentDto(
      id: 'doc-1',
      name: 'Test document',
      createdAtIso: '2026-09-15T10:00:00.000',
      entries: <ScanDocumentEntryDto>[
        ScanDocumentEntryDto(id: 'entry-1', photoPath: '/tmp/p1.jpg', text: 'hello'),
      ],
    );

    final ScanDocumentDto restored = ScanDocumentDto.fromJson(dto.toJson());

    expect(restored.id, dto.id);
    expect(restored.name, dto.name);
    expect(restored.createdAtIso, dto.createdAtIso);
    expect(restored.entries.single.id, 'entry-1');
    expect(restored.entries.single.text, 'hello');
  });

  test('the wireframe theme is black and white', () {
    final ThemeData theme = AppTheme.light();
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.primary, AppColors.ink);
  });

  testWidgets('the expandable OCR text box expands on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ExpandableTextBox(
            text: 'recognised text',
            status: OcrStatus.done,
          ),
        ),
      ),
    );

    expect(find.text('recognised text'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // The box is bottom-aligned inside the screen; tap its visible header
    // rather than the widget's centre so the tap lands on the InkWell.
    await tester.tap(find.text('OCR text'));
    await tester.pumpAndSettle();

    expect(find.text('recognised text'), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });
}
