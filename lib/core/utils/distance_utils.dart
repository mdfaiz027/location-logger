import 'package:geolocator/geolocator.dart';

class DistanceUtils {
  /// Calculate distance in meters between two coordinates using Haversine.
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Format meters to a readable string (km if > 1000).
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}