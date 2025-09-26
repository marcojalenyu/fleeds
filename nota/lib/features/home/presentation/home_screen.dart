import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/data/services/user_service.dart';
import 'package:nota/features/post/logic/post_controller.dart';
import 'package:nota/features/post/presentation/post_dialog.dart';
import 'package:nota/widgets/logo.dart';
import 'package:nota/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postController = PostController();
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final posts = await _postController.fetchPosts();
    setState(() {
      _posts = posts;
    });
  }

  Future<void> _showAddPostDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddPostDialog(user: AuthService.currentUser!),
    );

    final currentUser = AuthService.currentUser;

    if (result != null && currentUser != null) {
      final success = await _postController.addPost(
        currentUser.id,
        result['content'] ?? '',
      );
      if (success) {
        setState(() {}); // Refresh the UI to show the new post
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_postController.error ?? 'Unknown error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ClickableLogo(),
        actions: [
          IconButton(
            icon: CircleAvatar(child: Icon(Icons.person)), 
            onPressed: () {
              final user = AuthService.currentUser;
              if (user != null) {
                Navigator.of(context).pushNamed('/profile', arguments: user);
              }
            }
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Home',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                final user = UserService.getUserById(post.authorId);
                return PostCard(post: post, user: user!);
              },
            ),
          )
        ]
      ),      
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}