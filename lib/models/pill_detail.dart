class PillDetail {
  final int id;
  final String? name;             // ✅ nullable 처리
  final String? description;
  final String? warning;
  final String? usage;
  final String? imageUrl;
  final String? manufacturer;
  final int? dosePeriod;
  final String? doseTime;
  final bool? external;
  final int? externalId;

  PillDetail({
    required this.id,
    this.name,
    this.description,
    this.warning,
    this.usage,
    this.imageUrl,
    this.manufacturer,
    this.dosePeriod,
    this.doseTime,
    this.external,
    this.externalId,
  });

  factory PillDetail.fromJson(Map<String, dynamic> json) {
    return PillDetail(
      id: json['id'] as int,
      name: json['name'],
      description: json['description'],
      warning: json['warning'],
      usage: json['usage'],
      imageUrl: json['imageUrl'],
      manufacturer: json['manufacturer'],
      dosePeriod: json['dosePeriod'] as int?,
      doseTime: json['doseTime'],
      external: json['external'],
      externalId: json['externalId'],
    );
  }
}
