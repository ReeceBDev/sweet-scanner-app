import 'package:flutter_test/flutter_test.dart';

import 'package:sweet_scanner_app/state/document/scan_document.dart';

void main() {
  test('the entry title is the first line of recognised text', () {
    const DocumentEntry entry = DocumentEntry(
      id: 'entry-1',
      photoPath: '/tmp/p1.jpg',
      text: 'Grocery list\nmilk\neggs',
    );
    expect(entry.title, 'Grocery list');
    expect(entry.description, 'milk\neggs');
  });

  test('a single-line entry has a title and no description', () {
    const DocumentEntry entry = DocumentEntry(
      id: 'entry-1',
      photoPath: '/tmp/p1.jpg',
      text: 'just a heading',
    );
    expect(entry.title, 'just a heading');
    expect(entry.description, '');
  });

  test('empty recognised text yields an empty title and description', () {
    const DocumentEntry entry = DocumentEntry(
      id: 'entry-1',
      photoPath: '/tmp/p1.jpg',
      text: '',
    );
    expect(entry.title, '');
    expect(entry.description, '');
  });

  test('leading blank lines are skipped when picking the title', () {
    const DocumentEntry entry = DocumentEntry(
      id: 'entry-1',
      photoPath: '/tmp/p1.jpg',
      text: '\n \nReceipt\n1.00',
    );
    expect(entry.title, 'Receipt');
    expect(entry.description, '1.00');
  });

  test('blank lines inside the body are kept in the description', () {
    const DocumentEntry entry = DocumentEntry(
      id: 'entry-1',
      photoPath: '/tmp/p1.jpg',
      text: 'Heading\nfirst\n\nlast',
    );
    expect(entry.title, 'Heading');
    expect(entry.description, 'first\n\nlast');
  });
}
