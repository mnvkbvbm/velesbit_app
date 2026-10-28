import 'package:flutter/material.dart';
import '../../../core/models/group_model.dart';
import '../../../core/services/app_state.dart';
import '../widgets/crash_alert_banner.dart';
import '../widgets/live_ride_broadcast_card.dart';
import 'create_group_screen.dart';

class GroupsListScreen extends StatefulWidget {
  final AppState appState;

  const GroupsListScreen({super.key, required this.appState});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  String _selectedFilter = 'Tümü';
  String _searchQuery = '';

  final List<String> _filterCategories = ['Tümü', 'Takım', 'Dernek', 'Ekip', 'Topluluk'];

  List<GroupModel> get _filteredGroups {
    return widget.appState.groups.where((g) {
      final matchesFilter = _selectedFilter == 'Tümü' || g.type.label == _selectedFilter;
      final matchesSearch = g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruplar & Takımlar'),
      ),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, child) {
          final incidents = widget.appState.activeCrashIncidents;
          final broadcasts = widget.appState.activeGroupBroadcasts;

          return Column(
            children: [
              // Active Emergency Crash Alert Banners
              if (incidents.isNotEmpty)
                ...incidents.map((incident) {
                  return CrashAlertBanner(
                    incident: incident,
                    onNavigateToCrash: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${incident.riderName} kaza yerine rota çizildi.'),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    },
                    onResolve: () {
                      widget.appState.resolveCrashIncident(incident.id);
                    },
                  );
                }),

              // Live Team Broadcasts (48 Hours Retention)
              if (broadcasts.isNotEmpty)
                Container(
                  color: Colors.teal.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.sensors, color: Color(0xFF00A896), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Takım Canlı Yayınları (48 Sa Saklanır)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...broadcasts.map((b) => LiveRideBroadcastCard(broadcast: b)),
                    ],
                  ),
                ),

              // Search & Filter Header
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.primary.withOpacity(0.06),
                child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Grup, takım veya şehir ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterCategories.map((cat) {
                      final isSelected = _selectedFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = cat;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Groups List
          Expanded(
            child: _filteredGroups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aramanıza uygun grup bulunamadı.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroups[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        _getBadgeColor(group.type).withOpacity(0.15),
                                    child: Icon(
                                      _getBadgeIcon(group.type),
                                      color: _getBadgeColor(group.type),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            Text(
                                              ' ${group.city} • ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              group.type.label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getBadgeColor(group.type),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Member Count Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.people, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${group.memberCount}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                group.description,
                                style: TextStyle(color: Colors.grey[800], fontSize: 13.5),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kurucu: ${group.creatorName}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      widget.appState.toggleGroupMembership(group.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: group.isJoined
                                          ? Colors.grey[300]
                                          : theme.colorScheme.primary,
                                      foregroundColor:
                                          group.isJoined ? Colors.black87 : Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 13),
                                    ),
                                    icon: Icon(
                                      group.isJoined
                                          ? Icons.check
                                          : Icons.group_add_outlined,
                                      size: 16,
                                    ),
                                    label: Text(group.isJoined ? 'Katılındı' : 'Gruba Katıl'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  ),
  floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGroupScreen(appState: widget.appState),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Grup Oluştur'),
      ),
    );
  }

  Color _getBadgeColor(GroupType type) {
    switch (type) {
      case GroupType.takim:
        return Colors.orange.shade800;
      case GroupType.dernek:
        return Colors.blue.shade800;
      case GroupType.ekip:
        return const Color(0xFF00A896);
      case GroupType.topluluk:
        return Colors.purple.shade700;
    }
  }

  IconData _getBadgeIcon(GroupType type) {
    switch (type) {
      case GroupType.takim:
        return Icons.emoji_events;
      case GroupType.dernek:
        return Icons.account_balance;
      case GroupType.ekip:
        return Icons.directions_bike;
      case GroupType.topluluk:
        return Icons.groups;
    }
  }
}
