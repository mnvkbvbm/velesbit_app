import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/navigation_service.dart';

class NavigationScreen extends StatefulWidget {
  final AppState appState;

  const NavigationScreen({super.key, required this.appState});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navService = NavigationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<AddressSearchResult> _searchResults = [];
  AddressSearchResult? _selectedDestination;
  LatLng? _longPressedPoint;
  NavigationRoute? _currentRoute;

  bool _isSearching = false;
  bool _isCalculatingRoute = false;
  bool _isVoiceNavActive = false;
  bool _isSatellite = false;

  LatLng _liveLocation = const LatLng(40.9880, 29.0250);

  @override
  void initState() {
    super.initState();
    _liveLocation = LatLng(widget.appState.currentLat, widget.appState.currentLng);
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    final realLoc = await _getRealUserLocation();
    if (!mounted) return;
    setState(() {
      _liveLocation = realLoc;
    });
    try {
      _mapController.move(_liveLocation, 15.0);
    } catch (_) {}
  }

  Future<LatLng> _getRealUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        return LatLng(pos.latitude, pos.longitude);
      }
    } catch (_) {}
    return LatLng(widget.appState.currentLat, widget.appState.currentLng);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _navService.stopSpeech();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _navService.searchAddress(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _handleMapLongPress(LatLng tappedPoint) async {
    setState(() {
      _longPressedPoint = tappedPoint;
    });

    // Show Location Details Bottom Sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<LocationDetailInfo>(
          future: _navService.getLocationDetails(tappedPoint, _liveLocation),
          builder: (context, snapshot) {
            final theme = Theme.of(context);
            final details = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Header with Back Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Seçilen Konum Detayları',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  if (snapshot.connectionState == ConnectionState.waiting || details == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Adres ve rakım bilgileri sorgulanıyor...'),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Address Title
                    Text(
                      details.addressName.split(',').first,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 4),

                    // Area Summary (Mahalle • Semt • Köy • İlçe • Şehir)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_city_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              details.formattedAreaSummary,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Full Address Detail
                    Text(
                      details.addressName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid (Elevation, Distance, Coordinates)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailChip(
                          'Rakım (Yükseklik)',
                          '${details.elevationMeters.toStringAsFixed(0)} m',
                          Icons.terrain,
                          Colors.green.shade800,
                        ),
                        _buildDetailChip(
                          'Kuşuçuşu Mesafe',
                          '${details.distanceToUserKm} km',
                          Icons.straighten,
                          Colors.teal.shade800,
                        ),
                        _buildDetailChip(
                          'Koordinat',
                          '${tappedPoint.latitude.toStringAsFixed(3)}, ${tappedPoint.longitude.toStringAsFixed(3)}',
                          Icons.gps_fixed,
                          Colors.indigo.shade800,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Get Directions & Draw Route Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close sheet
                          _selectDestination(
                            AddressSearchResult(
                              displayName: details.addressName,
                              city: details.city,
                              location: details.location,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.navigation_rounded),
                        label: const Text(
                          'Yol Tarifi Al & Rota Çiz',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  Future<void> _selectDestination(AddressSearchResult result) async {
    FocusScope.of(context).unfocus();
    _searchController.text = result.displayName.split(',').first;

    setState(() {
      _selectedDestination = result;
      _searchResults = [];
      _isCalculatingRoute = true;
    });

    // Acquire REAL live GPS location as the starting point!
    final currentRealPos = await _getRealUserLocation();
    setState(() {
      _liveLocation = currentRealPos;
    });

    // Calculate Biking Route from user's REAL GPS location
    final route = await _navService.calculateCyclingRoute(
      currentRealPos,
      result.location,
    );

    if (!mounted) return;

    setState(() {
      _currentRoute = route;
      _isCalculatingRoute = false;
    });

    if (route != null && route.polylinePoints.isNotEmpty) {
      _mapController.move(result.location, 14.5);
    }
  }

  void _toggleVoiceNavigation() {
    setState(() {
      _isVoiceNavActive = !_isVoiceNavActive;
    });

    if (_isVoiceNavActive && _currentRoute != null && _currentRoute!.steps.isNotEmpty) {
      final firstStep = _currentRoute!.steps.first;
      _navService.speakInstruction('Bisiklet navigasyonu başladı. ${firstStep.instruction}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesli yönlendirme başlatıldı.'),
          backgroundColor: Colors.teal,
        ),
      );
    } else {
      _navService.stopSpeech();
    }
  }

  Future<void> _goToMyLocation() async {
    final pos = await _getRealUserLocation();
    setState(() {
      _liveLocation = pos;
    });
    try {
      _mapController.move(pos, 16.5);
    } catch (_) {}
  }

  void _clearRoute() {
    _navService.stopSpeech();
    setState(() {
      _selectedDestination = null;
      _longPressedPoint = null;
      _currentRoute = null;
      _isVoiceNavActive = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bisiklet Navigasyonu'),
      ),
      body: Stack(
        children: [
          // 1. FULL INTERACTIVE MAP WITH LONG PRESS LISTENER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _liveLocation,
              initialZoom: 16.0,
              maxZoom: 19.0,
              minZoom: 5.0,
              onLongPress: (tapPosition, point) => _handleMapLongPress(point),
            ),
            children: [
              // Base Tile Layer
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.velesbit',
              ),

              // Cadde, Bulvar, Sokak Yolları ve Cadde İsimleri (Satellite Mode)
              if (_isSatellite)
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.velesbit',
                ),

              // Hybrid Settlement Place Names Layer for Satellite Mode (Köy, Mahalle, İlçe, Şehir İsimleri)
              if (_isSatellite)
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.velesbit',
                ),

              // Polyline Route Layer
              if (_currentRoute != null && _currentRoute!.polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _currentRoute!.polylinePoints,
                      color: Colors.blue.shade700,
                      strokeWidth: 6.0,
                    ),
                  ],
                ),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // Real User Location Marker
                  Marker(
                    point: _liveLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A896),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                    ),
                  ),

                  // Long-pressed Tapped Point Marker
                  if (_longPressedPoint != null && _selectedDestination == null)
                    Marker(
                      point: _longPressedPoint!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.orangeAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        child: const Icon(Icons.pin_drop, color: Colors.white, size: 24),
                      ),
                    ),

                  // Destination Marker
                  if (_selectedDestination != null)
                    Marker(
                      point: _selectedDestination!.location,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. SEARCH BAR & SUGGESTIONS OVERLAY
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Input Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _performSearch(val),
                    decoration: InputDecoration(
                      hintText: 'Adres ara veya haritada bir yere basılı tut...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00A896)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearRoute,
                            )
                          : (_isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                // Search Results Dropdown List
                if (_searchResults.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final res = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.place_outlined, color: Color(0xFF00A896)),
                            title: Text(
                              res.displayName.split(',').first,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              res.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () => _selectDestination(res),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 3. MAP CONTROLS OVERLAY (Satellite & My Location)
          Positioned(
            top: 80,
            right: 16,
            child: Column(
              children: [
                // Layer Switcher
                FloatingActionButton.small(
                  heroTag: 'nav_layer',
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  onPressed: () {
                    setState(() {
                      _isSatellite = !_isSatellite;
                    });
                  },
                  child: Icon(_isSatellite ? Icons.map_outlined : Icons.satellite_alt_outlined),
                ),
                const SizedBox(height: 8),
                // Location Button
                FloatingActionButton.small(
                  heroTag: 'nav_location',
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // 4. ROUTE DETAILS & VOICE NAV BOTTOM SHEET
          if (_currentRoute != null && _selectedDestination != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF00A896),
                          child: Icon(Icons.directions_bike, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDestination!.displayName.split(',').first,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${_currentRoute!.totalDistanceKm} km • Tahmini ${_currentRoute!.totalDurationMinutes.toStringAsFixed(0)} dakika',
                                style: TextStyle(
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: _clearRoute,
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // First Turn Step Preview
                    if (_currentRoute!.steps.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.turn_right_rounded, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentRoute!.steps.first.instruction,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Start/Stop Voice Guidance Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _toggleVoiceNavigation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isVoiceNavActive ? Colors.redAccent : theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(_isVoiceNavActive ? Icons.volume_off : Icons.record_voice_over),
                        label: Text(
                          _isVoiceNavActive ? 'Sesli Yönlendirmeyi Durdur' : 'Sesli Navigasyonu Başlat',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_isCalculatingRoute)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Bisiklet Rotası Hesaplanıyor...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
