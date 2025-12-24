class PillCreateRequest {
  final int? id;
  final String name;
  final int dosePeriod;
  final String description;
  final bool external;
  final int? externalId;
  final String? imageUrl;
  final String? manufacturer;
  final String? color;
  final List<String> doseTimes;

  PillCreateRequest({
    this.id,
    required this.name,
    required this.dosePeriod,
    required this.description,
    required this.external,
    this.externalId,
    this.imageUrl,
    this.manufacturer,
    this.color,
    required this.doseTimes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosePeriod': dosePeriod,
      'description': description,
      'external': external,
      'externalId': externalId,
      'imageUrl': imageUrl,
      'manufacturer': manufacturer,
      'color': color,
      'doseTimes': doseTimes,
    };
  }
}