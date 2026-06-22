import 'package:location_logger_app/domain/entities/location_entity.dart';
import 'package:location_logger_app/domain/repositories/location_repository.dart';

class GetAllLogsUseCase {
  final LocationRepository repository;
  const GetAllLogsUseCase(this.repository);

  Future<List<LocationEntity>> call() async {
    return await repository.getAllLocations();
  }
}