import 'package:latlong2/latlong.dart';

class CrashIncident {
  final String id;
  final String riderName;
  final String riderPhone;
  final String bloodGroup;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  bool isResolved;

  CrashIncident({
    required this.id,
    required this.riderName,
    required this.riderPhone,
    required this.bloodGroup,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isResolved = false,
  });

  LatLng get location => LatLng(latitude, longitude);

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
