class MedicineResponse {
  final String? itemName;
  final String? entpName;
  final String? itemImage;
  final int? itemSeq;

  MedicineResponse({
    this.itemName,
    this.entpName,
    this.itemImage,
    this.itemSeq,
  });

  factory MedicineResponse.fromJson(Map<String, dynamic> json) {
    return MedicineResponse(
      itemName: json['itemName'],
      entpName: json['entpName'],
      itemImage: json['itemImage'],
      itemSeq: json['itemSeq'] is int
    ? json['itemSeq']
    : int.tryParse(json['itemSeq'] ?? ''),
    );
  }
}
