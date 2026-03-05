import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/components/search/presentation/search_panel.dart';
import 'package:fleeds/features/screens/notifications/logic/notifications_controller.dart';
import 'package:fleeds/widgets/bottom_bar.dart';
import 'package:fleeds/widgets/logo.dart';

/// A main scaffold widget that adapts its layout based on screen size.
class MainScaffold extends StatefulWidget {
  
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
  State<MainScaffold> createState() => _MainScaffoldState();
}

/// State for MainScaffold, responsible for managing notifications and handling navigation.
class _MainScaffoldState extends State<MainScaffold> {
  late final NotificationsController _notificationsController;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationsController = NotificationsController();
    _notificationsController.addListener(() {
      if (mounted) {
        setState(() {
          _unreadCount = _notificationsController.unreadCount;
        });
      }
    });
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _notificationsController.dispose();
    super.dispose();
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

  Future<void> _fetchUnreadCount() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final count = await _notificationsController.getUnreadCount(user.id);
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    }
  }

  /// Handles navigation based on the tapped index.
  void _onTap(BuildContext context, int index) {
    bool isMobile = MediaQuery.of(context).size.width < kDesktopBreakpoint;
    NavigationUtils.goToByIndex(context, index, isMobile);
  }

  /// Builds a menu item with an icon, label, and tap index (used for desktop layout).
  Widget _buildMenuItemDesktop(BuildContext context, IconData icon, String label, int index) {
    
    final isNotificationItem = label == 'Notifications';
    final hasUnread = _unreadCount > 0 && isNotificationItem;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextButton.icon(
            icon: Icon(icon, size: 24),
            label: Text(label, style: TextStyle(fontSize: 18)),
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => _onTap(context, index),
          ),
          if (hasUnread)
            Positioned(
              right: 4,
              top: -12,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Builds the mobile layout with a bottom navigation bar.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: widget.body,
      bottomNavigationBar: BottomBar(
        currentIndex: widget.currentIndex,
        unreadNotificationCount: _unreadCount,
        isAuthenticated: AuthService.isAuthenticated(),
        onTap: (index) => _onTap(context, index),
      ),
      floatingActionButton: widget.onAddPost != null
          ? FloatingActionButton(
        onPressed: widget.onAddPost,
        child: const Icon(Icons.add),
      )
          : null,
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
                _buildMenuItemDesktop(context, Icons.home, 'Home', 0),
                _buildMenuItemDesktop(context, Icons.person, 'Profile', 1),
                _buildMenuItemDesktop(context, Icons.notifications, 'Notifications', 2),
                _buildMenuItemDesktop(context, Icons.settings, 'Settings', 3),
                _buildMenuItemDesktop(context, Icons.logout, AuthService.isAuthenticated() ? 'Logout' : 'Login', 4),
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
              child: widget.body,
            ),
          ),
          // Search Panel:
          Flexible(
            flex: 2, /// 30%
            child: widget.searchPanel ?? SearchPanel(onSearch: (query) {}, results: []),
          ),
        ],
      ),
      floatingActionButton: widget.onAddPost != null
          ? FloatingActionButton(
              onPressed: widget.onAddPost,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}


