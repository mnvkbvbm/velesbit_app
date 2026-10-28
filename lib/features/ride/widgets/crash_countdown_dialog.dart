import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CrashCountdownDialog extends StatefulWidget {
  final VoidCallback onCancelled;
  final VoidCallback onConfirmed;

  const CrashCountdownDialog({
    super.key,
    required this.onCancelled,
    required this.onConfirmed,
  });

  @override
  State<CrashCountdownDialog> createState() => _CrashCountdownDialogState();
}

class _CrashCountdownDialogState extends State<CrashCountdownDialog> {
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        _vibratePulse();
      } else {
        _timer?.cancel();
        Navigator.pop(context); // Close dialog
        widget.onConfirmed();   // Trigger crash broadcast!
      }
    });
  }

  Future<void> _vibratePulse() async {
    try {
      final hasVib = await Vibration.hasVibrator();
      if (hasVib == true) {
        Vibration.vibrate(duration: 300);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cancelCrash() {
    _timer?.cancel();
    Navigator.pop(context);
    widget.onCancelled();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.red.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon with Pulsing Effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            const Text(
              '⚠️ KAZA ALGINLANDI!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              'Telefon sensörleriniz sert bir düşme/darbe tespit etti. 30 saniye içinde yanıt vermezseniz takım arkadaşlarınıza acil durum konumu gönderilecek!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Big Animated Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: _secondsRemaining / 30.0,
                    strokeWidth: 8,
                    color: Colors.amberAccent,
                    backgroundColor: Colors.white24,
                  ),
                ),
                Text(
                  '$_secondsRemaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // I'm OK / Cancel Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _cancelCrash,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 28),
                label: const Text(
                  'BEN İYİYİM (İPTAL ET)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
