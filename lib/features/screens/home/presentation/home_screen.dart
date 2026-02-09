import 'package:fleeds/features/screens/home/logic/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/components/add_post/presentation/add_post_dialog.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:fleeds/features/components/post/presentation/post_list.dart';

/// Home screen showing the feed of posts.
/// Keywords can be passed to filter the posts displayed on the home screen.
class HomeScreen extends StatefulWidget {

  final List<String>? keywords;
  const HomeScreen({super.key, this.keywords});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for HomeScreen, responsible for fetching and displaying posts, and handling user interactions.
class _HomeScreenState extends State<HomeScreen> {
  
  late final HomeController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(() => setState(() {}));
    final user = AuthService.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _controller.fetchPosts(keywords: widget.keywords ?? []);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Show the dialog for adding a new post.
  Future<void> _showAddPostDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AddPostDialog(
        user: AuthService.currentUser!,
        onPostAdded: () => _controller.fetchPosts(keywords: widget.keywords ?? []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0, 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 16.0),
            child: Text(
              'Home',
              style: Theme.of(context).textTheme.headlineLarge
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _controller.refreshPosts(keywords: widget.keywords ?? []),
              child: PostList(
                initialPosts: _controller.posts,
                onPostChanged: (_) => _controller.fetchPosts(keywords: widget.keywords ?? []),
              ),
            ),
          )
        ]
      ),
      onAddPost: () => _showAddPostDialog(context),
    );
  }
}


