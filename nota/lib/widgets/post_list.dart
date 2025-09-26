import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/widgets/post_card.dart';
import 'package:nota/data/services/user_service.dart';

class PostList extends StatefulWidget {
  final List<Post> initialPosts;
  final Future<List<Post>> Function()? onLoadMore;

  const PostList({
    super.key,
    required this.initialPosts,
    this.onLoadMore,
  });

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late List<Post> posts;
  final ScrollController _controller = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    posts = List.from(widget.initialPosts);
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosts != widget.initialPosts) {
      setState(() {
        posts = List.from(widget.initialPosts);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 && !_isLoading && widget.onLoadMore != null) {
      setState(() => _isLoading = true);
      final newPosts = await widget.onLoadMore!();
      setState(() {
        posts.addAll(newPosts);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      controller: _controller,
      itemCount: posts.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < posts.length) {
          final post = posts[index];
          final user = UserService.getUserById(post.authorId);
          return PostCard(post: post, user: user!);
        } else {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}