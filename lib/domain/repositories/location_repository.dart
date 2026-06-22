
import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<void> startTracking(String sessionId);
  Future<void> stopTracking();
  Future<void> saveLocation(LocationEntity location);
  Future<List<LocationEntity>> getAllLocations();
  Future<List<LocationEntity>> getLocationsBySession(String sessionId);
  Future<void> clearAll();
  Future<int> getTotalPoints();
  Future<LocationEntity?> getLastLocation();
  Future<double> getTotalDistanceForSession(String sessionId);
  bool get isTracking;
}