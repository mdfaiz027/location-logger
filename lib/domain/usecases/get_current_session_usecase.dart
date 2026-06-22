import 'package:location_logger_app/domain/repositories/location_repository.dart';

class GetCurrentSessionUseCase {
  final LocationRepository repository;
  const GetCurrentSessionUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    final isTracking = repository.isTracking;
    // We can get last location and total points from repo.
    final last = await repository.getLastLocation();
    final totalPoints = await repository.getTotalPoints();

    return {
      'isTracking': isTracking,
      'lastLocation': last,
      'totalPoints': totalPoints,
      'totalDistance': 0.0, // will be computed elsewhere
    };
  }
}