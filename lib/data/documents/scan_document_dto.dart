/// Serialisable shape of one photographed page: photo path + recognised text.
class ScanDocumentEntryDto {
  const ScanDocumentEntryDto({
    required this.id,
    required this.photoPath,
    required this.text,
  });

  factory ScanDocumentEntryDto.fromJson(Map<String, dynamic> json) {
    return ScanDocumentEntryDto(
      id: json['id'] as String,
      photoPath: json['photoPath'] as String,
      text: json['text'] as String? ?? '',
    );
  }

  final String id;
  final String photoPath;
  final String text;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'photoPath': photoPath,
      'text': text,
    };
  }
}

/// Serialisable shape of a stored scan document: id, name, creation time and
/// one entry per photographed page.
class ScanDocumentDto {
  const ScanDocumentDto({
    required this.id,
    required this.name,
    required this.createdAtIso,
    required this.entries,
  });

  factory ScanDocumentDto.fromJson(Map<String, dynamic> json) {
    return ScanDocumentDto(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAtIso: json['createdAt'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map(
            (dynamic entry) =>
                ScanDocumentEntryDto.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String id;
  final String name;
  final String createdAtIso;
  final List<ScanDocumentEntryDto> entries;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAtIso,
      'entries': entries
          .map((ScanDocumentEntryDto entry) => entry.toJson())
          .toList(),
    };
  }
}
