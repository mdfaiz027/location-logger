import 'package:location_logger_app/domain/repositories/location_repository.dart';

class StopTrackingUseCase {
  final LocationRepository repository;
  const StopTrackingUseCase(this.repository);

  Future<void> call() async {
    await repository.stopTracking();
  }
}