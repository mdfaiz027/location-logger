import 'package:geolocator/geolocator.dart';

class PermissionUtils {
  static Future<bool> requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // If we have "whileInUse", we try to get "always" for background tracking
    if (permission == LocationPermission.whileInUse) {
      // On iOS, we can proceed with whileInUse, and the system might prompt for Always later
      // or we can request it now. On Android 11+, Always must be requested separately.
      
      // For this app, we'll try to request Always but proceed even if we only have WhileInUse,
      // as the foreground service works with WhileInUse.
      final alwaysPermission = await Geolocator.requestPermission();
      if (alwaysPermission == LocationPermission.always) {
        return true;
      }
      
      // We still return true because WhileInUse is enough to start the service
      // (it will just be a foreground service).
      return true;
    }

    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  static Future<bool> checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
}
