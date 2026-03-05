import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/domain/models/notification.dart';
import 'package:fleeds/features/components/notification/logic/notification_card_controller.dart';
import 'package:fleeds/widgets/card.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:flutter/material.dart' hide Notification;

/// Widget to display a single notification in the notifications list
class NotificationCard extends StatefulWidget {

  final Notification notification;
  final VoidCallback? onDeleted;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onDeleted,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

/// State class for NotificationCard, manages the lifecycle and UI updates based on the NotificationCardController
class _NotificationCardState extends State<NotificationCard> {

  late final NotificationCardController _controller;
  late final Notification _notification;
  late final String type;

  @override
  void initState() {
    super.initState();
    _controller = NotificationCardController(notification: widget.notification);
    _controller.addListener(_onControllerChanged);
    _notification = widget.notification;
    type = _notification.type;
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Delete the notification and notify parent widget if successful
  void _handleDelete() async {
    final success = await _controller.deleteNotification();
    if (success && mounted) {
      widget.onDeleted?.call();
    }
  }

  /// Tapping leads to different actions based on notification type
  void _handleTap() {
    switch(type) {
      case 'like':
        NavigationUtils.goToPostById(context, _notification.relatedPostId!);
        break;
      case 'reply':
        NavigationUtils.goToPostById(context, _notification.relatedPostId!);
        break;
      case 'follow':
        NavigationUtils.goToProfileById(context, _notification.triggeredByUserId);
        break;
      default:
        break;
    }
  }

  Widget _buildNotificationIcon() {
    switch(type) {
      case 'like':
        return Icon(Icons.favorite, size: 28, color: Colors.red);
      case 'reply':
        return Icon(Icons.chat_bubble, size: 28, color: primaryColor);
      case 'follow':
        return Icon(Icons.person_add, size: 28, color: Colors.blue);
      default:
        return Icon(Icons.notifications, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      noPadding: true,
      child: Container(
        color: _notification.read ? Colors.white : Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Clickable(
                  onTap: _handleTap,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '@${_notification.triggeredByUsername}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' '),
                        TextSpan(text: _notification.displayBody),
                      ],
                    ),
                  ),
                ),
              ),
              if (_controller.isDeleting)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: _handleDelete,
                  tooltip: 'Delete notification',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}