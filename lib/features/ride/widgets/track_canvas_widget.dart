import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/ride_model.dart';

enum MapLayerType {
  street,
  satellite,
}

class TrackCanvasWidget extends StatefulWidget {
  final List<RoutePoint> points;
  final bool isLive;

  const TrackCanvasWidget({
    super.key,
    required this.points,
    this.isLive = false,
  });

  @override
  State<TrackCanvasWidget> createState() => _TrackCanvasWidgetState();
}

class _TrackCanvasWidgetState extends State<TrackCanvasWidget> {
  MapLayerType _currentLayer = MapLayerType.street;
  final MapController _mapController = MapController();

  // Tile URL templates
  static const String _streetTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _satelliteBaseTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String _satelliteTransportationTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}';
  static const String _satelliteLabelsTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}';

  Future<void> _goToCurrentLocation() async {
    try {
      if (widget.points.isNotEmpty) {
        _mapController.move(widget.points.last.latLng, 16.5);
      } else {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          16.5,
        );
      }
    } catch (_) {
      _mapController.move(const LatLng(40.9880, 29.0250), 16.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default center fallback (Kadıköy Sahil)
    final initialCenter = widget.points.isNotEmpty
        ? widget.points.last.latLng
        : const LatLng(40.9880, 29.0250);

    final polylineLatLngs = widget.points.map((p) => p.latLng).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // FlutterMap Tile Engine
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 16.0,
              maxZoom: 19.0,
              minZoom: 5.0,
            ),
            children: [
              // Base Map Tile Layer (Street vs Satellite)
              TileLayer(
                urlTemplate: _currentLayer == MapLayerType.street
                    ? _streetTileUrl
                    : _satelliteBaseTileUrl,
                userAgentPackageName: 'com.example.velesbit',
              ),

              // Cadde, Bulvar, Sokak Yolları ve İsimleri (Satellite Mode)
              if (_currentLayer == MapLayerType.satellite)
                TileLayer(
                  urlTemplate: _satelliteTransportationTileUrl,
                  userAgentPackageName: 'com.example.velesbit',
                ),

              // Köy, Mahalle, İlçe, Şehir Yerleşim İsimleri (Satellite Mode)
              if (_currentLayer == MapLayerType.satellite)
                TileLayer(
                  urlTemplate: _satelliteLabelsTileUrl,
                  userAgentPackageName: 'com.example.velesbit',
                ),

              // Polyline Track Layer
              if (polylineLatLngs.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylineLatLngs,
                      color: const Color(0xFF00A896),
                      strokeWidth: 5.0,
                    ),
                  ],
                ),

              // Markers Layer (Start & Current Position)
              if (widget.points.isNotEmpty)
                MarkerLayer(
                  markers: [
                    // Start Marker (Green Circle Pin)
                    Marker(
                      point: widget.points.first.latLng,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.flag, color: Colors.white, size: 18),
                      ),
                    ),

                    // Current Position / End Marker
                    Marker(
                      point: widget.points.last.latLng,
                      width: 42,
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isLive
                              ? const Color(0xFF00C49F)
                              : Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bike_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Floating Map Layer Switcher (Uydu / Şehir)
          Positioned(
            top: widget.isLive ? 120 : 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Şehir Haritası Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentLayer = MapLayerType.street;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentLayer == MapLayerType.street
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 16,
                            color: _currentLayer == MapLayerType.street
                                ? Colors.white
                                : Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Şehir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _currentLayer == MapLayerType.street
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Uydu Haritası Button (Cadde & Yerleşim İsimli)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _currentLayer = MapLayerType.satellite;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentLayer == MapLayerType.satellite
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.satellite_alt_outlined,
                            size: 16,
                            color: _currentLayer == MapLayerType.satellite
                                ? Colors.white
                                : Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Uydu (Cadde & İsimli)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _currentLayer == MapLayerType.satellite
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Re-center Location Button (Bottom Right)
          Positioned(
            bottom: widget.isLive ? 120 : 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: null,
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
