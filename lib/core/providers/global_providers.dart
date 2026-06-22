import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_local_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';

// Database instance (singleton)
final databaseProvider = Provider<LocationLocalDatasource>((ref) {
  return LocationLocalDatasource();
});

// Repository
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final datasource = ref.watch(databaseProvider);
  return LocationRepositoryImpl(datasource);
});
