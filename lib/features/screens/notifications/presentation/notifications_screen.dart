import 'package:fleeds/features/screens/notifications/logic/notifications_controller.dart';
import 'package:fleeds/features/components/notification/presentation/notification_card.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';

/// Screen to display user notifications, allowing users to view and interact with their notifications
class NotificationsScreen extends StatefulWidget {

  final String _userId;

  const NotificationsScreen({
    super.key,
    required String userId,
  }) : _userId = userId;
  
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

/// State class for NotificationsScreen, manages the lifecycle and UI updates based on the NotificationsController
class _NotificationsScreenState extends State<NotificationsScreen> {

  late NotificationsController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.addListener(_onControllerChanged);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialNotifications();
  }

  Future<void> _loadInitialNotifications() async {
    await _controller.fetchNotifications(userId: widget._userId, refresh: true);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      if (!_controller.isLoading && _controller.hasMore) {
        _controller.fetchNotifications(userId: widget._userId);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _controller.notifications;
    final isLoading = _controller.isLoading;
    final hasMore = _controller.hasMore;

    return MainScaffold(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: notifications.isEmpty && isLoading
            ? Center(child: CircularProgressIndicator())
            : notifications.isEmpty
              ? Center(child: Text('No notifications'))
              : RefreshIndicator(
                  onRefresh: () async => _loadInitialNotifications(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: notifications.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final notification = notifications[index];
                      return NotificationCard(
                        key: ValueKey(notification.id),
                        notification: notification,
                        onDeleted: () => _controller.removeNotification(notification.id),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}