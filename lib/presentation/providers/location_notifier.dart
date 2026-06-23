import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';
import '../../core/providers/global_providers.dart';

class LocationState {
  final bool isTracking;
  final LocationEntity? lastLocation;
  final int totalPoints;
  final double totalDistance; // in meters
  final String? error;

  LocationState({
    required this.isTracking,
    this.lastLocation,
    this.totalPoints = 0,
    this.totalDistance = 0.0,
    this.error,
  });

  LocationState copyWith({
    bool? isTracking,
    LocationEntity? lastLocation,
    int? totalPoints,
    double? totalDistance,
    String? error,
  }) {
    return LocationState(
      isTracking: isTracking ?? this.isTracking,
      lastLocation: lastLocation ?? this.lastLocation,
      totalPoints: totalPoints ?? this.totalPoints,
      totalDistance: totalDistance ?? this.totalDistance,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository repository;
  final StartTrackingUseCase startTrackingUseCase;
  final StopTrackingUseCase stopTrackingUseCase;

  Timer? _refreshTimer;
  String? _currentSessionId;

  LocationNotifier({
    required this.repository,
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
  }) : super(LocationState(isTracking: false)) {
    // Initial load
    refreshData();
  }

  Future<void> startTracking() async {
    try {
      final sessionId = await startTrackingUseCase();
      _currentSessionId = sessionId;
      state = state.copyWith(isTracking: true, error: null);
      _startAutoRefresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopTracking() async {
    try {
      await stopTrackingUseCase();
      _currentSessionId = null;
      state = state.copyWith(isTracking: false, error: null);
      _stopAutoRefresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) => refreshData());
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> refreshData() async {
    try {
      final isTracking = repository.isTracking;
      final last = await repository.getLastLocation();
      final totalPoints = await repository.getTotalPoints();
      final totalDistance = await repository.getLifetimeDistance();

      state = state.copyWith(
        isTracking: isTracking,
        lastLocation: last,
        totalPoints: totalPoints,
        totalDistance: totalDistance,
        error: null,
      );
    } catch (e) {
      // ignore error
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  final startUseCase = StartTrackingUseCase(repository);
  final stopUseCase = StopTrackingUseCase(repository);
  return LocationNotifier(
    repository: repository,
    startTrackingUseCase: startUseCase,
    stopTrackingUseCase: stopUseCase,
  );
});
