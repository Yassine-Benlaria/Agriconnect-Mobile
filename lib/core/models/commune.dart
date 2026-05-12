class Commune {
  final int id;
  final String nameLatin;
  final String nameArabic;
  final double lat;
  final double lng;
  final int wilayaId;

  const Commune({
    required this.id,
    required this.nameLatin,
    required this.nameArabic,
    required this.lat,
    required this.lng,
    required this.wilayaId,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: (json['id'] as num).toInt(),
      nameLatin: json['nameLatin'] as String,
      nameArabic: json['nameArabic'] as String,
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      wilayaId: (json['wilayaId'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameLatin': nameLatin,
        'nameArabic': nameArabic,
        'lat': lat,
        'lng': lng,
        'wilayaId': wilayaId,
      };

  @override
  String toString() => nameLatin;
}
