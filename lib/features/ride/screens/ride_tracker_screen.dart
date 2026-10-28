import 'package:flutter/material.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/crash_detection_service.dart';
import '../widgets/track_canvas_widget.dart';
import '../widgets/crash_countdown_dialog.dart';

class RideTrackerScreen extends StatefulWidget {
  final AppState appState;

  const RideTrackerScreen({super.key, required this.appState});

  @override
  State<RideTrackerScreen> createState() => _RideTrackerScreenState();
}

class _RideTrackerScreenState extends State<RideTrackerScreen> {
  final _titleController = TextEditingController();
  final CrashDetectionService _crashService = CrashDetectionService();
  late String _selectedBike;

  @override
  void initState() {
    super.initState();
    final bikes = widget.appState.currentUser.bikeTypes;
    _selectedBike = bikes.isNotEmpty ? bikes.first : 'Gravel';
    _startCrashSensorListener();
  }

  void _startCrashSensorListener() {
    _crashService.startListening(
      onCrashDetected: () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CrashCountdownDialog(
              onCancelled: () {
                _crashService.cancelCountdown();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kaza alarmı iptal edildi.'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              onConfirmed: () {
                _crashService.cancelCountdown();
                widget.appState.reportCrashIncident(
                  latitude: widget.appState.currentLat,
                  longitude: widget.appState.currentLng,
                  address: 'Canlı GPS Sürüş Konumu',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚨 ACİL: Kaza uyarısı gruptaki arkadaşlara iletildi!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _crashService.stopListening();
    super.dispose();
  }

  String _formatTimer(int secondsTotal) {
    final hours = secondsTotal ~/ 3600;
    final minutes = (secondsTotal % 3600) ~/ 60;
    final seconds = secondsTotal % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showStartModeSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sürüş Modunu Seçin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00A896),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sürüşünüzü yalnız yapabilir veya ekibinizle 48 saat canlı paylaşabilirsiniz.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Option 1: Yalnız Sür (Bireysel)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.black87),
                  ),
                  title: const Text('Yalnız Sür (Bireysel)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Sürüş verileriniz sadece kişisel geçmişinizde saklanır.', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    widget.appState.startRide(isLiveShared: false);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Canlı Paylaş (Takım & Ekip)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF00A896), width: 1.5),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5F3),
                    child: Icon(Icons.sensors, color: Color(0xFF00A896)),
                  ),
                  title: const Row(
                    children: [
                      Text('Canlı Paylaş (Takım & Ekip)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Chip(
                        label: Text('48 Saat', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: Color(0xFF00A896),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  subtitle: const Text('Takımınız ve gruplarınız sürüşünüzü canlı izler. Veri 48 saat saklanır.', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF00A896)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.appState.startRide(isLiveShared: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📡 Canlı sürüş yayını başlatıldı! Takımınız izleyebilir.'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showSaveDialog() {
    _titleController.text = 'Sürüş - ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';
    final userBikes = widget.appState.currentUser.bikeTypes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.save_outlined, color: Color(0xFF00A896)),
                  SizedBox(width: 10),
                  Text('Sürüşü Kaydet'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ride Stats Summary Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A896).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Mesafe', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              '${widget.appState.currentDistanceKm.toStringAsFixed(2)} km',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(height: 24, width: 1, color: Colors.grey[400]),
                        Column(
                          children: [
                            const Text('Süre', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              _formatTimer(widget.appState.currentDurationSeconds),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(height: 24, width: 1, color: Colors.grey[400]),
                        Column(
                          children: [
                            const Text('Ort. Hız', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              '${widget.appState.avgSpeedKmh.toStringAsFixed(1)} km/s',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00A896)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Sürüş Başlığı',
                      hintText: 'Örn: Sabah Sahil Turu',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBike,
                    decoration: const InputDecoration(
                      labelText: 'Kullanılan Bisiklet',
                      prefixIcon: Icon(Icons.pedal_bike),
                    ),
                    items: userBikes.map((bike) {
                      return DropdownMenuItem(value: bike, child: Text(bike));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          _selectedBike = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                // Sürüşü İptal Et
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.appState.cancelRide();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sürüş kaydı tutulmadan iptal edildi.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: const Text(
                    'Sürüşü İptal Et',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                // Devam Et
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Devam Et'),
                ),
                // Kaydet
                ElevatedButton(
                  onPressed: () {
                    widget.appState.stopAndSaveRide(
                      title: _titleController.text.trim(),
                      bikeType: _selectedBike,
                    );
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sürüş verileri başarıyla kaydedildi!'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = widget.appState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sürüş Takibi'),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          final isTracking = appState.isTracking;
          final isPaused = appState.isPaused;

          // FULL SCREEN MAP MODE WHEN TRACKING!
          if (isTracking) {
            return Stack(
              children: [
                // 1. FULL SCREEN INTERACTIVE MAP
                Positioned.fill(
                  child: TrackCanvasWidget(
                    points: appState.currentTrackPoints,
                    isLive: !isPaused,
                  ),
                ),

                // 2. TOP FLOATING DASHBOARD OVERLAY (Compact Glassmorphic Metrics)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D2D35).withOpacity(0.88),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPaused ? Icons.pause_circle : Icons.directions_bike,
                                  color: isPaused ? Colors.amber : const Color(0xFF00C49F),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPaused ? 'SÜRÜŞ DURAKLATILDI' : 'CANLI GPS SÜRÜŞÜ',
                                  style: TextStyle(
                                    color: isPaused ? Colors.amber : const Color(0xFF00C49F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatTimer(appState.currentDurationSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 16),

                        // Metrics Summary Line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Mesafe
                            _buildOverlayMetric(
                              'MESAFE',
                              '${appState.currentDistanceKm.toStringAsFixed(2)} km',
                              Colors.white,
                            ),
                            Container(height: 28, width: 1, color: Colors.white24),

                            // Anlık Hız
                            _buildOverlayMetric(
                              'ANLIK HIZ',
                              '${appState.currentSpeedKmh.toStringAsFixed(1)} km/s',
                              const Color(0xFF00C49F),
                            ),
                            Container(height: 28, width: 1, color: Colors.white24),

                            // Ortalama Hız
                            _buildOverlayMetric(
                              'ORT. HIZ',
                              '${appState.avgSpeedKmh.toStringAsFixed(1)} km/s',
                              Colors.lightBlueAccent,
                            ),
                            Container(height: 28, width: 1, color: Colors.white24),

                            // Yokuş Çıkış
                            _buildOverlayMetric(
                              'YOKUŞ ÇIKIŞ',
                              '+${appState.elevationGainM.toStringAsFixed(0)} m',
                              Colors.amber,
                            ),
                            Container(height: 28, width: 1, color: Colors.white24),

                            // Kalori
                            _buildOverlayMetric(
                              'KALORİ',
                              '${appState.caloriesBurned} kcal',
                              Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. BOTTOM FLOATING CONTROLS OVERLAY
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Duraklat / Devam Et
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (isPaused) {
                                  appState.resumeRide();
                                } else {
                                  appState.pauseRide();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isPaused ? Colors.teal : Colors.amber.shade800,
                                  width: 2,
                                ),
                                foregroundColor: isPaused ? Colors.teal : Colors.amber.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                              label: Text(
                                isPaused ? 'Devam Et' : 'Duraklat',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Bitir & Kaydet
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _showSaveDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text(
                                'Bitir & Kaydet',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // PRE-RIDE SCREEN (Before Start Ride)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Tracker Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'SÜRÜŞE BAŞLAMAYA HAZIR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Map Preview
                SizedBox(
                  height: 240,
                  child: TrackCanvasWidget(
                    points: appState.currentTrackPoints,
                    isLive: false,
                  ),
                ),
                const SizedBox(height: 20),

                // Main Metric Preview
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPreRideStat('Kullanılan Bisiklet', appState.currentUser.bikeTypes.isNotEmpty ? appState.currentUser.bikeTypes.first : 'Gravel', Icons.pedal_bike),
                        Container(height: 30, width: 1, color: Colors.grey[300]),
                        _buildPreRideStat('GPS Durumu', 'Hazır / Bağlı', Icons.gps_fixed),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Start Ride Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showStartModeSelectionDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 32),
                    label: const Text(
                      'SÜRÜŞÜ BAŞLAT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayMetric(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPreRideStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00A896), size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }
}
