import 'package:flutter/material.dart';

/// A bottom navigation bar with fixed items: 
/// Home, Profile, Search, Notifications, Logout.
class BottomBar extends StatelessWidget {

  final int _currentIndex;
  final ValueChanged<int> onTap;
  final int unreadNotificationCount;

  const BottomBar({
    super.key,
    required int currentIndex,
    required this.onTap,
    this.unreadNotificationCount = 0,
  }) : _currentIndex = currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: unreadNotificationCount > 0
              ? Badge(
                  label: Text(unreadNotificationCount > 99 ? '99+' : '$unreadNotificationCount'),
                  child: const Icon(Icons.notifications),
                )
              : const Icon(Icons.notifications),
          label: 'Alerts',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}


