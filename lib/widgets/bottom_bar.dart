import 'package:flutter/material.dart';

/// A bottom navigation bar with fixed items: 
/// Home, Profile, Search, Logout.
class BottomBar extends StatelessWidget {

  final int _currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    super.key,
    required int currentIndex,
    required this.onTap,
  }) : _currentIndex = currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}


