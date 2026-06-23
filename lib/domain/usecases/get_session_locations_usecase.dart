import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetSessionLocationsUseCase {
  final LocationRepository repository;
  const GetSessionLocationsUseCase(this.repository);

  Future<List<LocationEntity>> call(String sessionId) async {
    return await repository.getLocationsBySession(sessionId);
  }
}
