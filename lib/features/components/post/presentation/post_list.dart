import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/features/components/post/presentation/post_card.dart';
import 'package:fleeds/data/services/user_service.dart';

class PostList extends StatefulWidget {
  final List<Post> initialPosts;
  final Future<List<Post>> Function()? onLoadMore;
  final void Function(Post)? onPostChanged; 
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PostList({
    super.key,
    required this.initialPosts,
    this.onLoadMore,
    this.onPostChanged,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late List<Post> posts;
  ScrollController? _controller;
  bool _isLoading = false;

  final Map<String, User?> _users = {};
  bool _usersLoading = true;

  @override
  void initState() {
    super.initState();
    posts = List.from(widget.initialPosts);
    if (widget.onLoadMore != null && !widget.shrinkWrap) {
      _controller = ScrollController()..addListener(_onScroll);
    }
    _loadUsersForPosts(posts);
  }

  @override
  void didUpdateWidget(covariant PostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosts != widget.initialPosts) {
      setState(() {
        posts = List.from(widget.initialPosts);
        _users.clear();
      });
      _loadUsersForPosts(posts);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (_controller == null) return;
    if (_controller!.position.pixels >= _controller!.position.maxScrollExtent - 200 && !_isLoading && widget.onLoadMore != null) {
      setState(() => _isLoading = true);
      final newPosts = await widget.onLoadMore!();
      setState(() {
        posts.addAll(newPosts);
        _isLoading = false;
      });
      if (newPosts.isNotEmpty) {
        _loadUsersForPosts(newPosts);
      }
    }
  }

  // Fetch users for given posts (only those not already cached). Shows one loader for the whole list.
  Future<void> _loadUsersForPosts(List<Post> list) async {
    final idsToFetch = list.map((p) => p.authorId).toSet().where((id) => !_users.containsKey(id)).toList();
    if (idsToFetch.isEmpty) {
      if (mounted) setState(() => _usersLoading = false);
      return;
    }

    if (mounted) setState(() => _usersLoading = true);

    final svc = UserService();
    final Map<String, User?> fetched = {};

    for (final id in idsToFetch) {
      try {
        final user = await svc.fetchUser(id);
        fetched[id] = user;
      } catch (_) {
        fetched[id] = null;
      }
    }

    if (!mounted) return;
    setState(() {
      _users.addAll(fetched);
      _usersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_usersLoading) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (posts.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('No posts to display')),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      controller: _controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? (widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final user = _users[post.authorId];
        if (user == null) {
          // fallback if user failed to load
          return const Padding(padding: EdgeInsets.all(16.0));
        }
        return PostCard(post: post, user: user);
      },
    );
  }
}