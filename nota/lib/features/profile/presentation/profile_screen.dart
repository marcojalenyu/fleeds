import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/widgets/main_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFollowing = false;
  bool isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    isOwnProfile = AuthService.currentUser?.id == user.id;

    Widget profileBody = Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 120,
              color: Colors.grey[300],
              child: Center(child: Text('No Cover Photo')),
            ),
            Positioned(
              left: 16,
              bottom: -40,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
        SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('@${user.username}', style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Text("Bio"),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('${1} Followers'),
                  SizedBox(width: 16),
                  Text('${0} Following'),
                  Spacer(),
                  if (!isOwnProfile)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                        });
                      },
                      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                    ),
                ],
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Posts'),
            Tab(text: 'Replies'),
            Tab(text: 'Likes'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Center(child: Text('User Posts')),
              Center(child: Text('User Replies')),
              Center(child: Text('User Likes')),
            ],
          ),
        ),
      ],
    );

    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(
          title: Text('@${user.username}'),
        ),
        body: profileBody,
      ),
    );
  }
}