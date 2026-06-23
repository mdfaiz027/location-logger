import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/entities/session_entity.dart';
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
  bool isAppInForeground = true;

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      isAppInForeground = true;
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      isAppInForeground = false;
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

    late LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 5),
      );
    } else {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }

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

        // Notify user if app is in background
        if (!isAppInForeground) {
          final points = await db.getLocationsBySession(currentSessionId!);
          
          notificationsPlugin.show(
            888,
            AppStrings.appName,
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)} | Points: ${points.length}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'location_tracking_channel',
                'Location Tracking',
                importance: Importance.low,
                priority: Priority.low,
                ongoing: true,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: false,
              ),
            ),
          );
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

    final hasPermission = await PermissionUtils.requestLocationPermissions();
    if (!hasPermission) {
      throw Exception(AppStrings.permissionDenied);
    }

    // Request Notification Permissions specifically for iOS
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    await _initializeService();
    await _service.startService();
    
    Timer(const Duration(seconds: 1), () {
      _service.invoke('startTracking', {'sessionId': sessionId});
    });

    _isTracking = true;
  }

  Future<void> _initializeService() async {
    // Initialize for iOS
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracking_channel',
      'Location Tracking',
      importance: Importance.low,
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
  Future<void> saveLocation(LocationEntity location) async {}
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
  Future<List<SessionEntity>> getAllSessions() async {
    final metadata = await datasource.getSessionsMetadata();
    List<SessionEntity> sessions = [];

    for (var map in metadata) {
      final sessionId = map['session_id'] as String;
      final distance = await getTotalDistanceForSession(sessionId);
      
      sessions.add(SessionEntity(
        id: sessionId,
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
        pointsCount: map['points_count'] as int,
        totalDistance: distance,
      ));
    }
    return sessions;
  }

  @override
  Future<void> clearAll() async => await datasource.clearAll();
  @override
  Future<int> getTotalPoints() async => await datasource.countLocations();
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
      distance += DistanceUtils.calculateDistance(
        entities[i].latitude, entities[i].longitude,
        entities[i+1].latitude, entities[i+1].longitude,
      );
    }
    return distance;
  }

  @override
  Future<double> getLifetimeDistance() async {
    final entities = await getAllLocations();
    if (entities.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < entities.length - 1; i++) {
      final p1 = entities[i];
      final p2 = entities[i + 1];

      // Only calculate distance if points belong to the same session
      // to avoid jumps between separate journeys.
      if (p1.sessionId == p2.sessionId) {
        totalDistance += DistanceUtils.calculateDistance(
          p1.latitude, p1.longitude,
          p2.latitude, p2.longitude,
        );
      }
    }
    return totalDistance;
  }
}
