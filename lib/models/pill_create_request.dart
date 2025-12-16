class PillCreateRequest {
  final String name;
  final String doseTime;
  final int dosePeriod;
  final String description;
  final bool external;
  final int? externalId;

  final String? imageUrl;
  final String? manufacturer;

  PillCreateRequest({
    required this.name,
    required this.doseTime,
    required this.dosePeriod,
    required this.description,
    required this.external,
    this.externalId,
    this.imageUrl,
    this.manufacturer,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'doseTime': doseTime,
      'dosePeriod': dosePeriod,
      'description': description,
      'external': external,
      'externalId': externalId,
      'imageUrl': imageUrl,
      'manufacturer': manufacturer,
    };
  }
}