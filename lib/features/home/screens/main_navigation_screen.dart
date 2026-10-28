import 'package:flutter/material.dart';
import '../../../core/services/app_state.dart';
import '../../ride/screens/ride_tracker_screen.dart';
import '../../navigation/screens/navigation_screen.dart';
import '../../ride/screens/ride_history_screen.dart';
import '../../groups/screens/groups_list_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;

  const MainNavigationScreen({super.key, required this.appState});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;

    final List<Widget> screens = [
      RideTrackerScreen(appState: appState),
      NavigationScreen(appState: appState),
      RideHistoryScreen(appState: appState),
      GroupsListScreen(appState: appState),
      ProfileScreen(appState: appState),
    ];

    return PopScope(
      canPop: !appState.isTracking && _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (appState.isTracking) {
          // If ride is active, switch to Ride tab and notify user
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sürüş kaydı arka planda devam ediyor...'),
              backgroundColor: Colors.teal,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (_currentIndex != 0) {
          // Return to home tab
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00A896),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bike),
              activeIcon: Icon(Icons.directions_bike, size: 28),
              label: 'Sürüş',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation_outlined),
              activeIcon: Icon(Icons.navigation, size: 28),
              label: 'Navigasyon',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history, size: 28),
              label: 'Geçmiş',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups, size: 28),
              label: 'Gruplar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
