import '../entities/session_entity.dart';
import '../repositories/location_repository.dart';

class GetSessionsUseCase {
  final LocationRepository repository;
  const GetSessionsUseCase(this.repository);

  Future<List<SessionEntity>> call() async {
    return await repository.getAllSessions();
  }
}
