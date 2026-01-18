class Memo {
  final String id;
  final String title;
  final int colorValue;
  final DateTime createdAt;
  final bool isBold;

  Memo({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.createdAt,
    this.isBold = false,
  });

  Memo copyWith({
    String? id,
    String? title,
    int? colorValue,
    DateTime? createdAt,
    bool? isBold,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isBold: isBold ?? this.isBold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'isBold': isBold,
    };
  }

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String,
      title: json['title'] as String,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isBold: json['isBold'] as bool? ?? false,
    );
  }
}
