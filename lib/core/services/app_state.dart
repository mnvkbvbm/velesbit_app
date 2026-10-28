import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/ride_model.dart';
import '../models/crash_incident.dart';
import '../models/live_ride_broadcast.dart';

class AppState extends ChangeNotifier {
  // Auth State
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel _currentUser = UserModel(
    id: 'usr_1',
    fullName: 'Ahmet Yılmaz',
    email: 'ahmet@velesbit.com',
    phone: '0555 123 45 67',
    bloodGroup: 'A Rh+',
    bikeTypes: ['Gravel', 'MTB (Dağ Bisikleti)', 'E-Bike'],
  );

  UserModel get currentUser => _currentUser;

  // Saved credentials for "Beni Hatırla"
  String _savedEmail = '';
  String _savedPassword = '';
  bool _rememberMe = true;

  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;
  bool get rememberMe => _rememberMe;

  AppState() {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedEmail = prefs.getString('remember_email') ?? 'ahmet@velesbit.com';
      _savedPassword = prefs.getString('remember_password') ?? '123456';
      _rememberMe = prefs.getBool('remember_me') ?? true;

      final autoLogin = prefs.getBool('auto_login') ?? false;
      if (autoLogin && _savedEmail.isNotEmpty) {
        _currentUser.email = _savedEmail;
        _isLoggedIn = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  // Crash Detection State
  bool _crashProtectionEnabled = true;
  final List<CrashIncident> _activeCrashIncidents = [
    CrashIncident(
      id: 'crash_sample_1',
      riderName: 'Mehmet Demir',
      riderPhone: '0532 987 65 43',
      bloodGroup: '0 Rh+',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      latitude: 40.9820,
      longitude: 29.0280,
      address: 'Caddebostan Sahil Yolu, Kadıköy / İstanbul',
    ),
  ];

  bool get crashProtectionEnabled => _crashProtectionEnabled;
  List<CrashIncident> get activeCrashIncidents => List.unmodifiable(_activeCrashIncidents);

  void setCrashProtectionEnabled(bool value) {
    _crashProtectionEnabled = value;
    notifyListeners();
  }

  void reportCrashIncident({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    final incident = CrashIncident(
      id: 'crash_${DateTime.now().millisecondsSinceEpoch}',
      riderName: _currentUser.fullName,
      riderPhone: _currentUser.phone,
      bloodGroup: _currentUser.bloodGroup,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      address: address.isEmpty ? 'Canlı GPS Konumu ($latitude, $longitude)' : address,
    );
    _activeCrashIncidents.insert(0, incident);
    notifyListeners();
  }

  void resolveCrashIncident(String id) {
    _activeCrashIncidents.removeWhere((inc) => inc.id == id);
    notifyListeners();
  }

  // --- Live Group Broadcasts State (48 Hours Retention) ---
  bool _isLiveBroadcasting = false;
  LiveRideBroadcast? _currentLiveBroadcast;

  bool get isLiveBroadcasting => _isLiveBroadcasting;
  LiveRideBroadcast? get currentLiveBroadcast => _currentLiveBroadcast;

  final List<LiveRideBroadcast> _allGroupBroadcasts = [
    // Sample active team broadcast (Valid for 48 Hours)
    LiveRideBroadcast(
      id: 'broadcast_sample_1',
      riderId: 'usr_2',
      riderName: 'Can Öztürk',
      bikeType: 'E-Bike',
      bloodGroup: 'B Rh+',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 46)), // Expires in 46 hours
      currentLat: 40.9850,
      currentLng: 29.0290,
      distanceKm: 18.2,
      speedKmh: 24.5,
      durationSeconds: 3400,
      elevationGainM: 85.0,
      polylinePoints: [
        const LatLng(40.9880, 29.0250),
        const LatLng(40.9860, 29.0270),
        const LatLng(40.9850, 29.0290),
      ],
      isLiveActive: true,
    ),
  ];

  // Filtered broadcast list (Auto-cleans items older than 48 hours)
  List<LiveRideBroadcast> get activeGroupBroadcasts {
    _cleanupExpiredBroadcasts();
    return List.unmodifiable(_allGroupBroadcasts);
  }

  void _cleanupExpiredBroadcasts() {
    _allGroupBroadcasts.removeWhere((b) => b.isExpired);
  }

  // Initial Sample Groups
  final List<GroupModel> _groups = [
    GroupModel(
      id: 'grp_1',
      name: 'Marmara Gravel Ekibi',
      type: GroupType.ekip,
      description: 'Marmara bölgesindeki gravel ve arazi sürüş tutkunları.',
      city: 'İstanbul',
      memberCount: 42,
      isJoined: true,
      creatorName: 'Ahmet Yılmaz',
      createdDate: '10.01.2024',
    ),
    GroupModel(
      id: 'grp_2',
      name: 'Velesbit Bisiklet Derneği',
      type: GroupType.dernek,
      description: 'Şehir içi bisiklet ulaşımını yaygınlaştırma ve tur organizasyonları.',
      city: 'Ankara',
      memberCount: 128,
      isJoined: false,
      creatorName: 'Mehmet Demir',
      createdDate: '15.11.2023',
    ),
    GroupModel(
      id: 'grp_3',
      name: 'Ege Pedalları Takımı',
      type: GroupType.takim,
      description: 'Hafta sonu turları, yokuş antrenmanları ve amatör yarışlar.',
      city: 'İzmir',
      memberCount: 65,
      isJoined: true,
      creatorName: 'Zeynep Kaya',
      createdDate: '02.02.2024',
    ),
    GroupModel(
      id: 'grp_4',
      name: 'İstanbul E-Bike Topluluğu',
      type: GroupType.topluluk,
      description: 'Elektrikli bisiklet sürücüleri için rota ve şarj bilgi paylaşım grubu.',
      city: 'İstanbul',
      memberCount: 34,
      isJoined: false,
      creatorName: 'Can Öztürk',
      createdDate: '20.03.2024',
    ),
  ];

  List<GroupModel> get groups => List.unmodifiable(_groups);

  // Initial Sample Rides History
  final List<RideModel> _ridesHistory = [
    RideModel(
      id: 'ride_1',
      title: 'Kadıköy - Caddebostan Sahil Turu',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      distanceKm: 14.5,
      avgSpeedKmh: 19.8,
      maxSpeedKmh: 32.1,
      durationSeconds: 2630, // ~43dk
      pauseSeconds: 300,    // 5dk
      calories: 410,
      elevationGainM: 45.0,
      elevationLossM: 42.0,
      bikeType: 'Gravel',
      trackPoints: _generateSamplePoints(1),
    ),
    RideModel(
      id: 'ride_2',
      title: 'Belgrad Ormanı Doğa Sürüşü',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      distanceKm: 28.0,
      avgSpeedKmh: 17.5,
      maxSpeedKmh: 32.0,
      durationSeconds: 5760,
      pauseSeconds: 600,
      calories: 720,
      elevationGainM: 320.0,
      elevationLossM: 315.0,
      bikeType: 'MTB (Dağ Bisikleti)',
      trackPoints: _generateSamplePoints(2),
    ),
  ];

  List<RideModel> get ridesHistory => List.unmodifiable(_ridesHistory);

  // --- Live Ride Tracking State ---
  bool _isTracking = false;
  bool _isPaused = false;
  Timer? _durationTimer;
  StreamSubscription<Position>? _positionSubscription;

  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;

  int _currentDurationSeconds = 0;
  int _currentPauseSeconds = 0;
  double _currentDistanceKm = 0.0;
  double _currentSpeedKmh = 0.0;
  double _maxSpeedKmh = 0.0;
  double _avgSpeedKmh = 0.0;
  int _caloriesBurned = 0;
  double _elevationGainM = 0.0;
  double _elevationLossM = 0.0;
  final List<RoutePoint> _currentTrackPoints = [];

  int get currentDurationSeconds => _currentDurationSeconds;
  int get currentPauseSeconds => _currentPauseSeconds;
  double get currentDistanceKm => _currentDistanceKm;
  double get currentSpeedKmh => _currentSpeedKmh;
  double get maxSpeedKmh => _maxSpeedKmh;
  double get avgSpeedKmh => _avgSpeedKmh;
  int get caloriesBurned => _caloriesBurned;
  double get elevationGainM => _elevationGainM;
  double get elevationLossM => _elevationLossM;
  List<RoutePoint> get currentTrackPoints => List.unmodifiable(_currentTrackPoints);

  // Current Real Location Coordinates
  double _currentLat = 40.9880;
  double _currentLng = 29.0250;
  double _currentAltitude = 15.0;

  double get currentLat => _currentLat;
  double get currentLng => _currentLng;

  // --- Auth Methods with "Beni Hatırla" ---
  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    if (email.isNotEmpty && password.length >= 4) {
      _currentUser.email = email;
      _isLoggedIn = true;
      _rememberMe = rememberMe;

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('remember_email', email);
        await prefs.setString('remember_password', password);
        await prefs.setBool('remember_me', true);
        await prefs.setBool('auto_login', true);
      } else {
        await prefs.remove('remember_email');
        await prefs.remove('remember_password');
        await prefs.setBool('remember_me', false);
        await prefs.setBool('auto_login', false);
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  String? register({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
    required List<String> bikeTypes,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.isEmpty) return 'Lütfen ad soyad giriniz.';
    if (email.isEmpty || !email.contains('@')) return 'Geçerli bir e-posta adresi giriniz.';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalıdır.';
    if (password != confirmPassword) return 'Şifreler birbiriyle eşleşmiyor.';

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      bikeTypes: bikeTypes,
    );
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  bool forgotPassword(String email) {
    if (email.isNotEmpty && email.contains('@')) {
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_login', false);
    notifyListeners();
  }

  // --- Profile Methods ---
  void updateProfile({
    required String fullName,
    required String phone,
    required String bloodGroup,
    required List<String> bikeTypes,
  }) {
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      phone: phone,
      bloodGroup: bloodGroup,
      bikeTypes: bikeTypes,
    );
    notifyListeners();
  }

  // --- Group Methods ---
  void createGroup({
    required String name,
    required GroupType type,
    required String description,
    required String city,
  }) {
    final newGroup = GroupModel(
      id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      description: description,
      city: city,
      memberCount: 1,
      isJoined: true,
      creatorName: _currentUser.fullName,
      createdDate: '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
    );
    _groups.insert(0, newGroup);
    notifyListeners();
  }

  void toggleGroupMembership(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      final newJoined = !group.isJoined;
      _groups[index] = group.copyWith(
        isJoined: newJoined,
        memberCount: group.memberCount + (newJoined ? 1 : -1),
      );
      notifyListeners();
    }
  }

  static const MethodChannel _nativeForegroundChannel =
      MethodChannel('com.example.velesbit/foreground_service');

  Future<void> _startNativeForegroundService() async {
    try {
      await _nativeForegroundChannel.invokeMethod('startForegroundService');
    } catch (_) {}
  }

  Future<void> _stopNativeForegroundService() async {
    try {
      await _nativeForegroundChannel.invokeMethod('stopForegroundService');
    } catch (_) {}
  }

  // --- REAL GPS Live Ride Tracker (With "Canlı Paylaş" & 48h Retention) ---
  Future<void> startRide({bool isLiveShared = false}) async {
    _isTracking = true;
    _isPaused = false;
    _isLiveBroadcasting = isLiveShared;
    _currentDurationSeconds = 0;
    _currentPauseSeconds = 0;
    _currentDistanceKm = 0.0;
    _currentSpeedKmh = 0.0;
    _maxSpeedKmh = 0.0;
    _avgSpeedKmh = 0.0;
    _caloriesBurned = 0;
    _elevationGainM = 0.0;
    _elevationLossM = 0.0;
    _currentTrackPoints.clear();

    // Start Kotlin Native Foreground Service & WakeLock
    await _startNativeForegroundService();

    // Check GPS Permissions safely
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _currentAltitude = pos.altitude;
      }
    } catch (_) {
      _currentLat = 40.9880;
      _currentLng = 29.0250;
    }

    _addTrackPoint();

    // Create Live Broadcast Object (Valid for 48 Hours)
    if (_isLiveBroadcasting) {
      final userBike = _currentUser.bikeTypes.isNotEmpty ? _currentUser.bikeTypes.first : 'Gravel';
      _currentLiveBroadcast = LiveRideBroadcast(
        id: 'broadcast_${DateTime.now().millisecondsSinceEpoch}',
        riderId: _currentUser.id,
        riderName: _currentUser.fullName,
        bikeType: userBike,
        bloodGroup: _currentUser.bloodGroup,
        startTime: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 48)), // 48 Hours retention
        currentLat: _currentLat,
        currentLng: _currentLng,
        distanceKm: 0.0,
        speedKmh: 0.0,
        durationSeconds: 0,
        elevationGainM: 0.0,
        polylinePoints: [LatLng(_currentLat, _currentLng)],
        isLiveActive: true,
      );

      _allGroupBroadcasts.insert(0, _currentLiveBroadcast!);
    }

    // Duration Timer
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        _currentPauseSeconds++;
      } else {
        _currentDurationSeconds++;
        if (_isLiveBroadcasting && _currentLiveBroadcast != null) {
          _currentLiveBroadcast!.durationSeconds = _currentDurationSeconds;
        }
      }
      notifyListeners();
    });

    // Real GPS Stream Listener (Native Foreground Location Config)
    _positionSubscription?.cancel();
    try {
      late final LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: "🚴 Velesbit Canlı Sürüş Takibi",
            notificationText: "Sürüş verileriniz ve canlı konumunuz arka planda kesintisiz kaydediliyor...",
            notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
            enableWakeLock: true,
          ),
        );
      } else {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      }

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (_isPaused || !_isTracking) return;

        final double distanceInMeters = Geolocator.distanceBetween(
          _currentLat,
          _currentLng,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters >= 2.0) {
          final double distKm = distanceInMeters / 1000.0;
          _currentDistanceKm += distKm;

          final speedKmh = position.speed > 0
              ? (position.speed * 3.6)
              : (distKm / (1 / 3600.0));

          _currentSpeedKmh = speedKmh.clamp(0.0, 70.0);
          if (_currentSpeedKmh > _maxSpeedKmh) {
            _maxSpeedKmh = _currentSpeedKmh;
          }

          if (_currentDurationSeconds > 0) {
            _avgSpeedKmh = (_currentDistanceKm / (_currentDurationSeconds / 3600.0));
          }

          _caloriesBurned = (_currentDistanceKm * 28.5).round();

          if (position.altitude > _currentAltitude) {
            _elevationGainM += (position.altitude - _currentAltitude);
          } else {
            _elevationLossM += (_currentAltitude - position.altitude);
          }

          _currentLat = position.latitude;
          _currentLng = position.longitude;
          _currentAltitude = position.altitude;

          _addTrackPoint();

          // Sync Live Telemetry Broadcast for Team Members!
          if (_isLiveBroadcasting && _currentLiveBroadcast != null) {
            _currentLiveBroadcast!.currentLat = _currentLat;
            _currentLiveBroadcast!.currentLng = _currentLng;
            _currentLiveBroadcast!.distanceKm = _currentDistanceKm;
            _currentLiveBroadcast!.speedKmh = _currentSpeedKmh;
            _currentLiveBroadcast!.elevationGainM = _elevationGainM;
            _currentLiveBroadcast!.polylinePoints.add(LatLng(_currentLat, _currentLng));
          }

          notifyListeners();
        } else {
          _currentSpeedKmh = 0.0;
          if (_isLiveBroadcasting && _currentLiveBroadcast != null) {
            _currentLiveBroadcast!.speedKmh = 0.0;
          }
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}

    notifyListeners();
  }

  void pauseRide() {
    _isPaused = true;
    _currentSpeedKmh = 0.0;
    if (_currentLiveBroadcast != null) {
      _currentLiveBroadcast!.speedKmh = 0.0;
    }
    notifyListeners();
  }

  void resumeRide() {
    _isPaused = false;
    notifyListeners();
  }

  void _addTrackPoint() {
    _currentTrackPoints.add(
      RoutePoint(
        latitude: _currentLat,
        longitude: _currentLng,
        elevation: _currentAltitude,
        speedKmh: _currentSpeedKmh,
        timestamp: DateTime.now(),
      ),
    );
  }

  void stopAndSaveRide({required String title, required String bikeType}) {
    _durationTimer?.cancel();
    _durationTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _stopNativeForegroundService();

    if (_currentLiveBroadcast != null) {
      _currentLiveBroadcast!.isLiveActive = false; // Mark broadcast as completed (stored for 48h)
    }

    if (_currentDistanceKm >= 0.001) {
      final newRide = RideModel(
        id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
        title: title.isEmpty ? 'Kişisel Sürüş' : title,
        dateTime: DateTime.now(),
        distanceKm: double.parse(_currentDistanceKm.toStringAsFixed(2)),
        avgSpeedKmh: double.parse(_avgSpeedKmh.toStringAsFixed(1)),
        maxSpeedKmh: double.parse(_maxSpeedKmh.toStringAsFixed(1)),
        durationSeconds: _currentDurationSeconds,
        pauseSeconds: _currentPauseSeconds,
        calories: _caloriesBurned,
        elevationGainM: double.parse(_elevationGainM.toStringAsFixed(1)),
        elevationLossM: double.parse(_elevationLossM.toStringAsFixed(1)),
        bikeType: bikeType,
        trackPoints: List.from(_currentTrackPoints),
      );
      _ridesHistory.insert(0, newRide);
    }

    _isTracking = false;
    _isPaused = false;
    _isLiveBroadcasting = false;
    notifyListeners();
  }

  void cancelRide() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _stopNativeForegroundService();

    if (_currentLiveBroadcast != null) {
      _allGroupBroadcasts.removeWhere((b) => b.id == _currentLiveBroadcast!.id);
      _currentLiveBroadcast = null;
    }

    _isTracking = false;
    _isPaused = false;
    _isLiveBroadcasting = false;
    notifyListeners();
  }

  static List<RoutePoint> _generateSamplePoints(int seed) {
    final points = <RoutePoint>[];
    double lat = 40.9850 + (seed * 0.01);
    double lng = 29.0250 + (seed * 0.01);
    double alt = 15.0;
    final now = DateTime.now();

    for (int i = 0; i < 40; i++) {
      lat += 0.0003 + sin(i * 0.2) * 0.0001;
      lng += 0.0004 + cos(i * 0.2) * 0.0001;
      alt += sin(i * 0.5) * 2;
      points.add(
        RoutePoint(
          latitude: lat,
          longitude: lng,
          elevation: alt,
          speedKmh: 18.0 + sin(i * 0.2) * 4,
          timestamp: now.subtract(Duration(minutes: 40 - i)),
        ),
      );
    }
    return points;
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
