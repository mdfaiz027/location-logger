import 'package:location_logger_app/domain/repositories/location_repository.dart';

class ClearAllLogsUseCase {
  final LocationRepository repository;
  const ClearAllLogsUseCase(this.repository);

  Future<void> call() async {
    await repository.clearAll();
  }
}