import 'package:flutter/material.dart';
import '../../../core/services/app_state.dart';
import 'ride_detail_screen.dart';

class RideHistoryScreen extends StatelessWidget {
  final AppState appState;

  const RideHistoryScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Sürüşler'),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          final rides = appState.ridesHistory;

          // Calculate Total Aggregates
          double totalKm = 0;
          double totalElevation = 0;
          int totalSeconds = 0;

          for (final r in rides) {
            totalKm += r.distanceKm;
            totalElevation += r.elevationGainM;
            totalSeconds += r.durationSeconds;
          }

          final totalHours = totalSeconds / 3600.0;

          return Column(
            children: [
              // Overall Aggregate Summary Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.primary.withOpacity(0.08),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Toplam Sürüş İstatistikleri',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Toplam Mesafe',
                              '${totalKm.toStringAsFixed(1)} km',
                              Icons.directions_bike,
                              Colors.teal,
                            ),
                            _buildStatItem(
                              'Sürüş Sayısı',
                              '${rides.length}',
                              Icons.flag,
                              Colors.amber.shade800,
                            ),
                            _buildStatItem(
                              'Süre',
                              '${totalHours.toStringAsFixed(1)} sa',
                              Icons.timer,
                              Colors.indigo,
                            ),
                            _buildStatItem(
                              'Yokuş Çıkış',
                              '+${totalElevation.toStringAsFixed(0)} m',
                              Icons.terrain,
                              Colors.green.shade800,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Ride History List
              Expanded(
                child: rides.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pedal_bike_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Henüz kaydedilmiş sürüş bulunmuyor.',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sürüş ekranından ilk sürüşünüzü başlatabilirsiniz!',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                                child: Icon(
                                  Icons.directions_bike,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                ride.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${ride.dateTime.day}.${ride.dateTime.month}.${ride.dateTime.year}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          ' • ${ride.bikeType}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _buildChipBadge(
                                          '${ride.distanceKm} km',
                                          Icons.straighten,
                                          Colors.teal.shade800,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildChipBadge(
                                          ride.formattedDuration,
                                          Icons.access_time,
                                          Colors.indigo.shade800,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildChipBadge(
                                          '${ride.avgSpeedKmh} km/s',
                                          Icons.speed,
                                          Colors.amber.shade900,
                                        ),
                                        const SizedBox(width: 6),
                                        _buildChipBadge(
                                          '+${ride.elevationGainM}m',
                                          Icons.terrain,
                                          Colors.green.shade800,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideDetailScreen(ride: ride),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChipBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
