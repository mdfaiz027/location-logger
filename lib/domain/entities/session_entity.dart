class SessionEntity {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int pointsCount;
  final double totalDistance;

  SessionEntity({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.pointsCount,
    required this.totalDistance,
  });
}
