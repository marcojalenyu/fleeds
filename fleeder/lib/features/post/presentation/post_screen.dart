import 'package:flutter/material.dart';
import 'package:fleeder/core/utils/date_utils.dart';
import 'package:fleeder/core/utils/navigation_utils.dart';
import 'package:fleeder/data/models/post.dart';
import 'package:fleeder/data/models/user.dart';
import 'package:fleeder/data/services/auth_service.dart';
import 'package:fleeder/data/services/user_service.dart';
import 'package:fleeder/features/post/logic/post_controller.dart';
import 'package:fleeder/widgets/clickable.dart';
import 'package:fleeder/widgets/main_scaffold.dart';
import 'package:fleeder/widgets/post_list.dart';
import 'package:fleeder/widgets/profile_pic.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  final Post? post;
  final User? user;
  final void Function(Post)? onPostChanged;
  const PostScreen({
    super.key,
    required this.postId,
    this.post,
    this.user,
    this.onPostChanged,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final currentUser = AuthService.currentUser;
  late PostController _postController;
  bool _loading = true;
  late User user;
  List<Post> replies = [];

  final contentTextStyle = const TextStyle(fontSize: 20);
  final textStyle = const TextStyle(fontSize: 16);
  bool isLiking = false;
  bool _loadingReplies = false;

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  void _toggleReplyFocus() {
    if (_replyFocusNode.hasFocus) {
      _replyFocusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(_replyFocusNode);
    }
  }

  Future<void> _replyToPost() async {
    if (_replyController.text.isNotEmpty && currentUser != null) {
      final newReplyId = await _postController.replyToPost(
        _postController.post!.id,
        currentUser!.id,
        _replyController.text,
      );
      if (newReplyId.isNotEmpty) {
        widget.onPostChanged?.call(_postController.post!);
        await _loadReplies();
      }
      _replyController.clear();
      _toggleReplyFocus();
    }
  }

  Future<void> _toggleLikeBy(User? user) async {
    if (user == null || isLiking) return;

    setState(() {
      isLiking = true;
    });

    final success = await _postController.likePost(_postController.post!.id, user.id);

    setState(() {
      isLiking = false;
      if (success && _postController.post != null) {
        widget.onPostChanged?.call(_postController.post!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _postController = PostController();
    if (widget.post != null && widget.user != null) {
      _postController.post = widget.post!;
      user = widget.user!;
      _loading = false;
      _loadReplies();
    } else {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    await _postController.fetchPost(widget.postId);
    final post = _postController.post;
    if (post == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final fetchedUser = await UserService.getUserById(post.authorId);
    if (fetchedUser == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    user = fetchedUser;
    await _loadReplies();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadReplies() async {
    setState(() {
      _loadingReplies = true;
    });
    replies = await _postController.fetchReplies(_postController.post!.id);
    setState(() {
      _loadingReplies = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = _postController.post;
    if (_loading || post == null) {
      return MainScaffold(
        currentIndex: 0,
        body: Scaffold(
          appBar: AppBar(),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClickableProfilePic(user: user, imageUrl: ''),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Clickable(
                        onTap: () => goToProfile(context, user),
                        child: Text(
                          user.displayName,
                          style: textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('@${user.username}', style: textStyle.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content, style: contentTextStyle),
              const SizedBox(height: 12),
              Text(DisplayDateUtils.displayDate(post.createdAt), style: textStyle.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Divider(thickness: 1, color: Colors.grey[300], height: 12),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${post.commentCount}', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('Replies', style: textStyle.copyWith(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Text('${post.likeCount}', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('Likes', style: textStyle.copyWith(color: Colors.grey[600])),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 6),
              Divider(thickness: 1, color: Colors.grey[300], height: 12),
              const SizedBox(height: 6),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Clickable(
                        onTap: _toggleReplyFocus,
                        child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Clickable(
                        onTap: () {
                          if (!isLiking) {
                            _toggleLikeBy(currentUser);
                          }
                        },
                        child: Icon(
                          post.likedBy(currentUser!.id) ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: post.likedBy(currentUser!.id) ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Divider(thickness: 1, color: Colors.grey[300], height: 12),
              const SizedBox(height: 8),
              TextField(
                controller: _replyController,
                focusNode: _replyFocusNode,
                maxLength: 128,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
                style: textStyle,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _replyToPost,
                  child: Text('Reply'),
                ),
              ),
              const SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey[300], height: 12),
              const SizedBox(height: 16),
              _loadingReplies
                  ? Center(child: CircularProgressIndicator())
                  : replies.isEmpty
                      ? Center(child: Text('No replies yet.', style: textStyle))
                      : PostList(
                          initialPosts: replies,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          onPostChanged: (updatedPost) {
                            setState(() {
                              final index = replies.indexWhere((p) => p.id == updatedPost.id);
                              if (index != -1) {
                                replies[index] = updatedPost;
                              }
                              if (post.id == updatedPost.id) {
                                // This is rare for replies, but keep for consistency
                                _postController.post = updatedPost;
                              }
                            });
                            widget.onPostChanged?.call(updatedPost);
                          },
                      )
            ],
          ),
        ),
      ),
    );
  }
}
