class Wilaya {
  final int id;
  final String nameLatin;
  final String nameArabic;
  final int code;

  const Wilaya({
    required this.id,
    required this.nameLatin,
    required this.nameArabic,
    required this.code,
  });

  factory Wilaya.fromJson(Map<String, dynamic> json) {
    return Wilaya(
      id: (json['id'] as num).toInt(),
      nameLatin: json['nameLatin'] as String,
      nameArabic: json['nameArabic'] as String,
      code: (json['code'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameLatin': nameLatin,
        'nameArabic': nameArabic,
        'code': code,
      };

  @override
  String toString() => nameLatin;
}
