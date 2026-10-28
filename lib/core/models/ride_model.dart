import 'package:latlong2/latlong.dart';

class RoutePoint {
  final double latitude;
  final double longitude;
  final double elevation; // Altitude in meters
  final double speedKmh; // Speed at this point
  final DateTime timestamp;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.speedKmh,
    required this.timestamp,
  });

  // Getters for x/y compatibility
  double get x => longitude;
  double get y => latitude;

  LatLng get latLng => LatLng(latitude, longitude);
}

class RideModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final double distanceKm;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final int durationSeconds;
  final int pauseSeconds;
  final int calories;
  final double elevationGainM;
  final double elevationLossM;
  final String bikeType;
  final List<RoutePoint> trackPoints;

  RideModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.distanceKm,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.durationSeconds,
    required this.pauseSeconds,
    required this.calories,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.bikeType,
    required this.trackPoints,
  });

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours}s ${minutes}dk ${seconds}sn';
    }
    return '${minutes}dk ${seconds}sn';
  }

  String get formattedPause {
    final minutes = pauseSeconds ~/ 60;
    final seconds = pauseSeconds % 60;
    return '${minutes}dk ${seconds}sn';
  }
}
