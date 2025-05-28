class PillSummary {
  final int id;
  final String name;
  final String? imageUrl;
  final String? manufacturer;
  final String doseTime;
  final int dosePeriod;
  final int takenDays;
  final int takenPercent;
  final String? description;
  

  PillSummary({
    required this.id,
    required this.name,
    this.imageUrl,
    this.manufacturer,
    required this.doseTime,
    required this.dosePeriod,
    required this.takenDays,
    required this.takenPercent,
    this.description,
  });

  factory PillSummary.fromJson(Map<String, dynamic> json) {
    return PillSummary(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      manufacturer: json['manufacturer'],
      doseTime: json['doseTime'],
      dosePeriod: json['dosePeriod'],
      takenDays: json['takenDays'],
      takenPercent: json['takenPercent'],
      description: json['description'],
    );
  }
}