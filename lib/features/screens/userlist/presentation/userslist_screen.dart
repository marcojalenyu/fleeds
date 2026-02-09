import 'package:flutter/material.dart';
import 'package:fleeds/features/screens/userlist/logic/userslist_controller.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:fleeds/features/components/user/presentation/user_card.dart';

/// Screen to display a list of users, either followers or following, based on the provided user ID and type
class UsersListScreen extends StatefulWidget {
  
  final String _userId;
  final String _type; // 'Followers' or 'Following'

  const UsersListScreen({
    super.key,
    required String userId,
    required String type,
  }) : _type = type, _userId = userId;

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

/// State class for UsersListScreen, manages the lifecycle and UI updates based on the UsersListController
class _UsersListScreenState extends State<UsersListScreen> {
  
  late UsersListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UsersListController(widget._userId, widget._type);
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
    final isLoading = _controller.isLoading;

    return MainScaffold(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(title: Text(widget._type)),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: isLoading
            ? Center(child: CircularProgressIndicator())
            : users.isEmpty
              ? Center(child: Text('No users found'))
              : RefreshIndicator(
                  onRefresh: () => _controller.refresh(widget._userId),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(user: user);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}


