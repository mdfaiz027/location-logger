import 'package:uuid/uuid.dart';

import '../repositories/location_repository.dart';

class StartTrackingUseCase {
  final LocationRepository repository;
  const StartTrackingUseCase(this.repository);

  Future<String> call() async {
    final sessionId = const Uuid().v4();
    await repository.startTracking(sessionId);
    return sessionId;
  }
}