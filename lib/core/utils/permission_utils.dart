import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestLocationPermissions() async {
    // Request both "when in use" and "always" (for background)
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Try again
      final secondStatus = await Permission.location.request();
      if (secondStatus.isDenied) {
        return false;
      }
    }

    // On Android, also request background location permission
    if (await Permission.location.isGranted) {
      final background = await Permission.locationAlways.request();
      if (background.isDenied) {
        // We can still track in foreground, but background may be limited
        // For this app, we want background, so we'll return false if denied permanently.
        if (background.isPermanentlyDenied) {
          return false;
        }
        // If just denied, we can still proceed but will lack background.
        // We'll return true but log a warning.
        return true;
      }
      return true;
    }
    return false;
  }

  static Future<bool> checkPermissions() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      // Check always permission for iOS / background for Android
      final always = await Permission.locationAlways.status;
      // Actually we want always for background; if denied, we may still start but background won't work.
      // For simplicity, we require always.
      return always.isGranted;
    }
    return false;
  }
}