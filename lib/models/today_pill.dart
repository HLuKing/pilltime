class TodayPill {
  final int id;
  final String name;
  final String doseTime;
  final bool taken;

  TodayPill({
    required this.id,
    required this.name,
    required this.doseTime,
    required this.taken,
  });

  factory TodayPill.fromJson(Map<String, dynamic> json) {
    return TodayPill(
      id: json['id'],
      name: json['name'],
      doseTime: json['doseTime'],
      taken: json['taken'],
    );
  }
}
