import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../core/utils/distance_utils.dart';
import '../../core/utils/permission_utils.dart';
import '../../core/constants/app_strings.dart';
import '../datasources/location_local_datasource.dart';
import '../models/location_model.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();

  String? currentSessionId;
  StreamSubscription<Position>? positionSubscription;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    positionSubscription?.cancel();
    service.stopSelf();
  });

  service.on('startTracking').listen((event) {
    currentSessionId = event?['sessionId'];
    if (currentSessionId == null) return;

    positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );

    positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        final db = LocationLocalDatasource();
        final model = LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
          sessionId: currentSessionId!,
        );
        await db.insertLocation(model);

        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            final points = await db.getLocationsBySession(currentSessionId!);
            
            FlutterLocalNotificationsPlugin().show(
              888,
              AppStrings.appName,
              'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)} | Points: ${points.length}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'location_tracking_channel',
                  'Location Tracking',
                  importance: Importance.high,
                  priority: Priority.high,
                  ongoing: true,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
            );
          }
        }
      },
    );
  });
}

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDatasource datasource;
  bool _isTracking = false;

  final FlutterBackgroundService _service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  LocationRepositoryImpl(this.datasource);

  @override
  bool get isTracking => _isTracking;

  @override
  Future<void> startTracking(String sessionId) async {
    if (_isTracking) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception(AppStrings.permissionPermanentlyDenied);
    }

    final hasPermission = await PermissionUtils.requestLocationPermissions();
    if (!hasPermission) {
      throw Exception(AppStrings.permissionDenied);
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled. Please enable them and try again.');
    }

    await _initializeService();
    await _service.startService();
    
    // Give it a moment to start then send the sessionId
    Timer(const Duration(seconds: 1), () {
      _service.invoke('startTracking', {'sessionId': sessionId});
    });

    _isTracking = true;
  }

  Future<void> _initializeService() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracking_channel',
      'Location Tracking',
      description: 'Shows that location tracking is active.',
      importance: Importance.high,
      enableVibration: false,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking_channel',
        initialNotificationTitle: AppStrings.appName,
        initialNotificationContent: 'Tracking is active...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (service) async => true,
        autoStart: false,
      ),
    );
  }

  @override
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _service.invoke('stopService');
    _isTracking = false;
    await _notifications.cancel(888);
  }

  @override
  Future<void> saveLocation(LocationEntity location) async {
    final model = LocationModel.fromEntity(location);
    await datasource.insertLocation(model);
  }

  @override
  Future<List<LocationEntity>> getAllLocations() async {
    final models = await datasource.getAllLocations();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<LocationEntity>> getLocationsBySession(String sessionId) async {
    final models = await datasource.getLocationsBySession(sessionId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> clearAll() async {
    await datasource.clearAll();
  }

  @override
  Future<int> getTotalPoints() async {
    return await datasource.countLocations();
  }

  @override
  Future<LocationEntity?> getLastLocation() async {
    final model = await datasource.getLastLocation();
    return model?.toEntity();
  }

  @override
  Future<double> getTotalDistanceForSession(String sessionId) async {
    final entities = await getLocationsBySession(sessionId);
    if (entities.length < 2) return 0.0;

    double distance = 0.0;
    for (int i = 0; i < entities.length - 1; i++) {
      final p1 = entities[i];
      final p2 = entities[i + 1];
      distance += DistanceUtils.calculateDistance(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
    }
    return distance;
  }
}
