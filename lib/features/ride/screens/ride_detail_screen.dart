import 'package:flutter/material.dart';
import '../../../core/models/ride_model.dart';
import '../widgets/track_canvas_widget.dart';

class RideDetailScreen extends StatelessWidget {
  final RideModel ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ride.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date & Bike Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${ride.dateTime.day}.${ride.dateTime.month}.${ride.dateTime.year} - ${ride.dateTime.hour.toString().padLeft(2, '0')}:${ride.dateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Chip(
                  avatar: const Icon(Icons.pedal_bike, size: 16, color: Colors.white),
                  label: Text(
                    ride.bikeType,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Track Route Map Canvas
            SizedBox(
              height: 220,
              child: TrackCanvasWidget(
                points: ride.trackPoints,
                isLive: false,
              ),
            ),
            const SizedBox(height: 16),

            // Distance & Duration Summary Banner
            Card(
              elevation: 2,
              color: theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'TOPLAM MESAFE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ride.distanceKm} km',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 36, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        const Text(
                          'SÜRÜŞ SÜRESİ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ride.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Grid Metrics
            Text(
              'Sürüş Detayları',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _buildMetricCard(
                  icon: Icons.speed,
                  title: 'ORTALAMA HIZ',
                  value: '${ride.avgSpeedKmh} km/s',
                  color: Colors.teal.shade700,
                ),
                _buildMetricCard(
                  icon: Icons.bolt,
                  title: 'MAKSİMUM HIZ',
                  value: '${ride.maxSpeedKmh} km/s',
                  color: Colors.amber.shade800,
                ),
                _buildMetricCard(
                  icon: Icons.timer,
                  title: 'DİNLENME SÜRESİ',
                  value: ride.formattedPause,
                  color: Colors.indigo.shade700,
                ),
                _buildMetricCard(
                  icon: Icons.local_fire_department,
                  title: 'KALORİ',
                  value: '${ride.calories} kcal',
                  color: Colors.orange.shade800,
                ),
                _buildMetricCard(
                  icon: Icons.terrain,
                  title: 'YOKUŞ ÇIKIŞ',
                  value: '+${ride.elevationGainM} m',
                  color: Colors.green.shade800,
                ),
                _buildMetricCard(
                  icon: Icons.south_east,
                  title: 'YOKUŞ İNİŞ',
                  value: '-${ride.elevationLossM} m',
                  color: Colors.blue.shade800,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
