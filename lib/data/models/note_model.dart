class NoteModel {
  final int? id;
  final String title;
  final String subject;
  final String content;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.subject,
    required this.content,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      content: map['content'] as String? ?? '',
      colorHex: map['colorHex'] as String? ?? '#7C6AFA',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'subject': subject,
      'content': content,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? subject,
    String? content,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
