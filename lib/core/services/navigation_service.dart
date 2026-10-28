import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddressSearchResult {
  final String displayName;
  final String city;
  final LatLng location;

  AddressSearchResult({
    required this.displayName,
    required this.city,
    required this.location,
  });

  factory AddressSearchResult.fromJson(Map<String, dynamic> json) {
    final lat = double.parse(json['lat'].toString());
    final lon = double.parse(json['lon'].toString());
    final address = json['address'] as Map<String, dynamic>?;
    final city = address?['city'] ?? address?['town'] ?? address?['state'] ?? 'Türkiye';

    return AddressSearchResult(
      displayName: json['display_name'] ?? '',
      city: city.toString(),
      location: LatLng(lat, lon),
    );
  }
}

class LocationDetailInfo {
  final String addressName;
  final String neighborhood; // Mahalle / Semt
  final String district;     // İlçe / Belde
  final String village;      // Köy / Yayla
  final String city;         // Şehir / İl
  final String road;         // Cadde / Sokak
  final LatLng location;
  final double elevationMeters;
  final double distanceToUserKm;

  LocationDetailInfo({
    required this.addressName,
    required this.neighborhood,
    required this.district,
    required this.village,
    required this.city,
    required this.road,
    required this.location,
    required this.elevationMeters,
    required this.distanceToUserKm,
  });

  String get formattedAreaSummary {
    final parts = <String>[];
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (village.isNotEmpty) parts.add(village);
    if (district.isNotEmpty) parts.add(district);
    if (city.isNotEmpty) parts.add(city);

    if (parts.isEmpty) return 'Bilinmeyen Bölge';
    return parts.join(' • ');
  }
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final LatLng location;

  RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.location,
  });
}

class NavigationRoute {
  final List<LatLng> polylinePoints;
  final double totalDistanceKm;
  final double totalDurationMinutes;
  final List<RouteStep> steps;

  NavigationRoute({
    required this.polylinePoints,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.steps,
  });
}

class NavigationService {
  final FlutterTts _tts = FlutterTts();

  NavigationService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> speakInstruction(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stopSpeech() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  // 1. FREE OpenStreetMap Nominatim Geocoding Search
  Future<List<AddressSearchResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=6&countrycodes=tr',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'VelesbitCyclingApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => AddressSearchResult.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 2. Reverse Geocoding & Elevation lookup with Mahalle, İlçe, Köy, Şehir details
  Future<LocationDetailInfo> getLocationDetails(LatLng point, LatLng userLocation) async {
    String addressName = 'Seçilen Konum (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
    String neighborhood = '';
    String district = '';
    String village = '';
    String city = 'Türkiye';
    String road = '';
    double elevation = 25.0; // Fallback altitude in meters

    // Reverse Geocode via Nominatim
    try {
      final revUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&addressdetails=1',
      );
      final response = await http.get(
        revUrl,
        headers: {'User-Agent': 'VelesbitCyclingApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          addressName = data['display_name'].toString();
          final addr = data['address'] as Map<String, dynamic>?;
          if (addr != null) {
            neighborhood = (addr['neighbourhood'] ?? addr['suburb'] ?? addr['quarter'] ?? '').toString();
            district = (addr['district'] ?? addr['subdistrict'] ?? addr['borough'] ?? addr['town'] ?? '').toString();
            village = (addr['village'] ?? addr['hamlet'] ?? addr['isolated_dwelling'] ?? '').toString();
            city = (addr['city'] ?? addr['province'] ?? addr['state'] ?? 'Türkiye').toString();
            road = (addr['road'] ?? addr['pedestrian'] ?? addr['footway'] ?? '').toString();
          }
        }
      }
    } catch (_) {}

    // Elevation Lookup via Open-Meteo
    try {
      final elevUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${point.latitude}&longitude=${point.longitude}&current_weather=true',
      );
      final response = await http.get(elevUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['elevation'] != null) {
          elevation = (data['elevation'] as num).toDouble();
        }
      }
    } catch (_) {}

    // Distance Calculation
    final double distMeters = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      point.latitude,
      point.longitude,
    );

    return LocationDetailInfo(
      addressName: addressName,
      neighborhood: neighborhood,
      district: district,
      village: village,
      city: city,
      road: road,
      location: point,
      elevationMeters: elevation,
      distanceToUserKm: double.parse((distMeters / 1000.0).toStringAsFixed(1)),
    );
  }

  // 3. FREE OSRM Cycling Routing Machine
  Future<NavigationRoute?> calculateCyclingRoute(LatLng start, LatLng destination) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/biking/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&steps=true',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final primaryRoute = routes.first;
          final double distanceKm = (primaryRoute['distance'] ?? 0.0) / 1000.0;
          final double durationMinutes = (primaryRoute['duration'] ?? 0.0) / 60.0;

          // Polyline Coordinates
          final List coordinates = primaryRoute['geometry']['coordinates'];
          final polylinePoints = coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          // Turn-by-Turn Steps
          final List<RouteStep> steps = [];
          final legs = primaryRoute['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final legSteps = legs.first['steps'] as List?;
            if (legSteps != null) {
              for (final step in legSteps) {
                final String modifier = step['maneuver']?['modifier'] ?? '';
                final String type = step['maneuver']?['type'] ?? '';
                final double distMeters = (step['distance'] ?? 0.0).toDouble();
                final List loc = step['maneuver']?['location'] ?? [0, 0];

                String turkishInstruction = _translateStepToTurkish(type, modifier, distMeters);
                steps.add(
                  RouteStep(
                    instruction: turkishInstruction,
                    distanceMeters: distMeters,
                    location: LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble()),
                  ),
                );
              }
            }
          }

          return NavigationRoute(
            polylinePoints: polylinePoints,
            totalDistanceKm: double.parse(distanceKm.toStringAsFixed(1)),
            totalDurationMinutes: double.parse(durationMinutes.toStringAsFixed(0)),
            steps: steps,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  String _translateStepToTurkish(String type, String modifier, double distanceMeters) {
    String formattedDist = distanceMeters > 1000
        ? '${(distanceMeters / 1000.0).toStringAsFixed(1)} km'
        : '${distanceMeters.toStringAsFixed(0)} metre';

    if (type == 'depart') {
      return '$formattedDist sürün ve başlayın.';
    } else if (type == 'arrive') {
      return 'Hedefinize ulaştınız!';
    } else if (type == 'turn') {
      if (modifier.contains('left')) {
        return '$formattedDist sonra sola dönün.';
      } else if (modifier.contains('right')) {
        return '$formattedDist sonra sağa dönün.';
      } else if (modifier.contains('straight')) {
        return '$formattedDist boyunca düz devam edin.';
      }
      return '$formattedDist sonra dönün.';
    } else if (type == 'roundabout') {
      return '$formattedDist sonra döner kavşaktan geçin.';
    }
    return '$formattedDist boyunca rotayı takip edin.';
  }
}
