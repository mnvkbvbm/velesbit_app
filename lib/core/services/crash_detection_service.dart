import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

class CrashDetectionService {
  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  bool _isEnabled = true;
  bool _isCountdownActive = false;
  DateTime? _lastCrashTriggerTime;

  bool get isEnabled => _isEnabled;
  bool get isCountdownActive => _isCountdownActive;

  // Sensitivity threshold: 3.2g G-force acceleration spike
  static const double crashThresholdGForce = 31.0; // ~3.2g in m/s^2 (3.2 * 9.81 = 31.39)

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopListening();
    }
  }

  void startListening({required Function() onCrashDetected}) {
    if (!_isEnabled || _sensorSubscription != null) return;

    _sensorSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!_isEnabled || _isCountdownActive) return;

      // Cooldown check (prevent multiple triggers within 20 seconds)
      if (_lastCrashTriggerTime != null) {
        final diff = DateTime.now().difference(_lastCrashTriggerTime!);
        if (diff.inSeconds < 20) return;
      }

      // Calculate magnitude of G-force acceleration: sqrt(x^2 + y^2 + z^2)
      final double gForceMagnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Trigger potential crash if threshold is exceeded
      if (gForceMagnitude >= crashThresholdGForce) {
        _lastCrashTriggerTime = DateTime.now();
        _isCountdownActive = true;
        _triggerVibration();
        onCrashDetected();
      }
    });
  }

  void stopListening() {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _isCountdownActive = false;
  }

  void cancelCountdown() {
    _isCountdownActive = false;
  }

  Future<void> _triggerVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000]);
      }
    } catch (_) {}
  }
}
