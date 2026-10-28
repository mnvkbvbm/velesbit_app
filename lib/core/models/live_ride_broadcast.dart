import 'package:latlong2/latlong.dart';

class LiveRideBroadcast {
  final String id;
  final String riderId;
  final String riderName;
  final String bikeType;
  final String bloodGroup;
  final DateTime startTime;
  final DateTime expiresAt; // 48 Hours retention
  double currentLat;
  double currentLng;
  double distanceKm;
  double speedKmh;
  int durationSeconds;
  double elevationGainM;
  List<LatLng> polylinePoints;
  bool isLiveActive;

  LiveRideBroadcast({
    required this.id,
    required this.riderId,
    required this.riderName,
    required this.bikeType,
    required this.bloodGroup,
    required this.startTime,
    required this.expiresAt,
    required this.currentLat,
    required this.currentLng,
    required this.distanceKm,
    required this.speedKmh,
    required this.durationSeconds,
    required this.elevationGainM,
    required this.polylinePoints,
    required this.isLiveActive,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  LatLng get currentLocation => LatLng(currentLat, currentLng);

  String get remainingHoursText {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inHours > 0) {
      return '${diff.inHours} saat kaldı';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika kaldı';
    }
    return 'Süresi doldu';
  }
}
