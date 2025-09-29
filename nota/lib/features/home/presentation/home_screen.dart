import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/features/post/logic/post_controller.dart';
import 'package:nota/features/post/presentation/post_dialog.dart';
import 'package:nota/widgets/main_scaffold.dart';
import 'package:nota/widgets/post_list.dart';

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
        await _fetchPosts();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_postController.error ?? 'Unknown error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0, // Home tab
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
            child: PostList(
              initialPosts: _posts,
              onPostChanged: (_) => _fetchPosts(),
            ),
          )
        ]
      ),
      onAddPost: () => _showAddPostDialog(context),
    );
  }
}