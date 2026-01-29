import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/search/presentation/search_panel.dart';
import 'package:fleeds/features/search/presentation/search_screen.dart';
import 'package:fleeds/widgets/bottom_bar.dart';
import 'package:fleeds/widgets/logo.dart';

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
          // Mobile: navigate to SearchScreen
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

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu Panel: 20%
          Flexible(
            flex: 2, // 20%
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding (
                  padding: const EdgeInsets.all(16.0),
                  child: ClickableLogo(),
                ),
                const SizedBox(height: 32.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.home, size: 24),
                    label: Text('Home', style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                    onPressed: () => _onTap(context, 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.person, size: 24),
                    label: Text('Profile', style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                    onPressed: () => _onTap(context, 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.notifications, size: 24),
                    label: Text('Notifications', style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                    onPressed: () => _onTap(context, 2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.logout, size: 24),
                    label: Text('Logout', style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                    onPressed: () => _onTap(context, 3),
                  ),
                ),
              ],
            ),
          ),
          // Main Content: 50%
          Flexible(
            flex: 6, // 50%
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
          // Search Panel: 30%
          Flexible(
            flex: 2, // 30%
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

