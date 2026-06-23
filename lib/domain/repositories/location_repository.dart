import '../entities/location_entity.dart';
import '../entities/session_entity.dart';

abstract class LocationRepository {
  Future<void> startTracking(String sessionId);
  Future<void> stopTracking();
  Future<void> saveLocation(LocationEntity location);
  Future<List<LocationEntity>> getAllLocations();
  Future<List<LocationEntity>> getLocationsBySession(String sessionId);
  Future<List<SessionEntity>> getAllSessions();
  Future<void> clearAll();
  Future<int> getTotalPoints();
  Future<LocationEntity?> getLastLocation();
  Future<double> getTotalDistanceForSession(String sessionId);
  Future<double> getLifetimeDistance();
  bool get isTracking;
}
