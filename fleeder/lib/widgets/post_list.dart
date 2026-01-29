import 'package:flutter/material.dart';
import 'package:fleeds/data/models/post.dart';
import 'package:fleeds/widgets/post_card.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/data/models/user.dart';

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

  @override
  void initState() {
    super.initState();
    posts = List.from(widget.initialPosts);
    if (widget.onLoadMore != null && !widget.shrinkWrap) {
      _controller = ScrollController()..addListener(_onScroll);
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      controller: _controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? (widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: posts.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < posts.length) {
          final post = posts[index];
          return FutureBuilder<User?>(
            future: UserService.getUserById(post.authorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('User not found')),
                );
              }
              return PostCard(
                post: post,
                user: snapshot.data!,
                onPostChanged: (updatedPost) {
                  setState(() {
                    final idx = posts.indexWhere((p) => p.id == updatedPost.id);
                    if (idx != -1) posts[idx] = updatedPost;
                  });
                  if (widget.onPostChanged != null) widget.onPostChanged!(updatedPost);
                },
              );
            },
          );
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

