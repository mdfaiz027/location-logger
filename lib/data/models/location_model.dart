
import 'package:location_logger_app/domain/entities/location_entity.dart';

class LocationModel {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String sessionId;

  LocationModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
      sessionId: map['session_id'],
    );
  }

  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      sessionId: sessionId,
    );
  }

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      sessionId: entity.sessionId,
    );
  }
}