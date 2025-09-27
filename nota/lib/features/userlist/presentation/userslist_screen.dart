import 'package:flutter/material.dart';
import 'package:nota/features/userlist/logic/userslist_controller.dart';
import 'package:nota/widgets/main_scaffold.dart';
import 'package:nota/widgets/profile_pic.dart';

class UsersListScreen extends StatefulWidget {
  final String userId;
  final String type; // 'Followers' or 'Following'

  const UsersListScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late UsersListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UsersListController(widget.userId, widget.type);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = _controller.users;

    return MainScaffold(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(title: Text(widget.type)),
        body: users.isEmpty
            ? Center(child: Text('No users found'))
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: ProfilePic(user: user, size: 32),
                    title: Text(user.displayName),
                    subtitle: Text('@${user.username}'),
                  );
                },
              ),
      ),
    );
  }
}