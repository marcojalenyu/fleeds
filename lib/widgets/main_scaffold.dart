import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/components/search/presentation/search_panel.dart';
import 'package:fleeds/features/screens/search/presentation/search_screen.dart';
import 'package:fleeds/widgets/bottom_bar.dart';
import 'package:fleeds/widgets/logo.dart';

/// A main scaffold widget that adapts its layout based on screen size.
class MainScaffold extends StatelessWidget {
  
  final int currentIndex;
  final Widget body;
  final Widget? searchPanel;
  final VoidCallback? onAddPost;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    this.searchPanel,
    this.onAddPost,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < kDesktopBreakpoint) {
        return _buildMobileLayout(context);
      } else {
        return _buildDesktopLayout(context);
      }
    });
  }

  /// Handles navigation based on the tapped index.
  /// Home: 0, Profile: 1, Search/Notification: 2, Logout: 3
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.of(context).pushNamed('/profile', arguments: AuthService.currentUser);
        break;
      case 2:
        if (MediaQuery.of(context).size.width < kDesktopBreakpoint) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SearchScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This feature is not yet available.')),
          );
        }
        break;
      case 3:
        AuthService.logout();
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  /// Builds a menu item with an icon, label, and tap index.
  Widget _buildMenuItem(BuildContext context, IconData icon, String label, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft),
        onPressed: () => _onTap(context, index),
      ),
    );
  }
  
  /// Builds the mobile layout with a bottom navigation bar.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPost,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the desktop layout with a side menu and optional search panel.
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu Panel
          Flexible(
            flex: 2, /// 20%
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding (
                  padding: const EdgeInsets.all(16.0),
                  child: ClickableLogo(),
                ),
                const SizedBox(height: 32.0),
                _buildMenuItem(context, Icons.home, 'Home', 0),
                _buildMenuItem(context, Icons.person, 'Profile', 1),
                _buildMenuItem(context, Icons.notifications, 'Notifications', 2),
                _buildMenuItem(context, Icons.logout, 'Logout', 3),
              ],
            ),
          ),
          // Main Content
          Flexible(
            flex: 6, /// 60%
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey, width: 0.5),
                  left: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: body,
            ),
          ),
          // Search Panel:
          Flexible(
            flex: 2, /// 30%
            child: searchPanel ?? SearchPanel(onSearch: (query) {}, results: []),
          ),
        ],
      ),
      floatingActionButton: onAddPost != null
          ? FloatingActionButton(
              onPressed: onAddPost,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}


