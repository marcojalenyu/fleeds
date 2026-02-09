import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/date_utils.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:fleeds/features/components/post/presentation/post_list.dart';
import 'package:fleeds/widgets/profile_pic.dart';

/// Screen to display a single post with its details and replies
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
  bool _loadingReplies = false;

  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  late bool isLiking = false;
  late bool isLiked = false;
  late int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _postController = PostController();
    if (widget.post != null && widget.user != null) {
      _postController.post = widget.post!;
      user = widget.user!;
      isLiked = widget.post!.isLikedBy(currentUser?.id ?? '');
      likeCount = widget.post!.likeCount;
      _loading = false;
      _loadReplies();
    } else {
      _loadPost();
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    await _postController.fetchPost(widget.postId);
    final post = _postController.post;
    if (post == null) {
      setState(() => _loading = false);
      return;
    }  
    final fetchedUser = await UserService().fetchUser(post.authorId);
    if (fetchedUser == null) {
      setState(() => _loading = false);
      return;
    }
    user = fetchedUser;
    isLiked = post.isLikedBy(currentUser?.id ?? '');
    likeCount = post.likeCount;
    await _loadReplies();
    setState(() => _loading = false);
  }

  Future<void> _loadReplies() async {
    setState(() => _loadingReplies = true);
    replies = await _postController.fetchReplies(_postController.post!.id);
    setState(() => _loadingReplies = false);
  }

  void _toggleReplyFocus() {
    if (_replyFocusNode.hasFocus) {
      _replyFocusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(_replyFocusNode);
    }
  }

  Future<void> _toggleLike() async {
    if (currentUser == null || isLiking) return;

    setState(() {
      isLiking = true;
      isLiked = !isLiked; // optimistic update
      likeCount += isLiked ? 1 : -1;
    });

    final success = await _postController.toggleLike(currentUser!.id);

    setState(() {
      isLiking = false;
    });

    if (success && _postController.post != null) {
      widget.onPostChanged?.call(_postController.post!); // backend sync
    }
  }

  Future<void> _replyToPost() async {
    if (_replyController.text.isEmpty || currentUser == null) return;
    final newReplyId = await _postController.replyToPost(
      _replyController.text,
      currentUser!.id,
      _postController.post!.id,
    );
    if (newReplyId != null) {
      _replyController.clear();
      _toggleReplyFocus();
      await _loadReplies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _postController.post;
    if (_loading || post == null) {
      return MainScaffold(
        currentIndex: 0,
        body: Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MainScaffold(
      currentIndex: 1,
      body: Scaffold(
        appBar: AppBar(),
        body: RefreshIndicator(
          onRefresh: _loadPost,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(),
                const SizedBox(height: 12),
                SelectableText(post.content, style: contentTextStyle),
                const SizedBox(height: 12),
                Text(
                  DisplayDateUtils.displayDate(post.createdAt),
                  style: textStyle.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Divider(thickness: 1, color: Colors.grey[300], height: 12),
                const SizedBox(height: 6),
                _buildStats(),
                const SizedBox(height: 6),
                Divider(thickness: 1, color: Colors.grey[300], height: 12),
                const SizedBox(height: 6),
                _buildActions(),
                const SizedBox(height: 6),
                Divider(thickness: 1, color: Colors.grey[300], height: 12),
                const SizedBox(height: 8),
                _buildReplyField(),
                const SizedBox(height: 8),
                Divider(thickness: 1, color: Colors.grey[300], height: 12),
                const SizedBox(height: 16),
                _buildReplies(),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
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
            Text(
              '@${user.username}',
              style: textStyle.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Text('${_postController.post!.replyCount}', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text('Replies', style: textStyle.copyWith(color: Colors.grey[600])),
        const SizedBox(width: 16),
        Text('$likeCount', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text('Likes', style: textStyle.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActions() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Clickable(
                onTap: _toggleReplyFocus,
                child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Clickable(
                onTap: () => _toggleLike(),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyField() {
    return Column(
      children: [
        TextField(
          controller: _replyController,
          focusNode: _replyFocusNode,
          maxLength: 128,
          minLines: 3,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          ),
          style: textStyle,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _replyToPost,
            child: const Text('Reply'),
          ),
        ),
      ],
    );
  }

  Widget _buildReplies() {
    if (_loadingReplies) {
      return const Center(child: CircularProgressIndicator());
    }
    if (replies.isEmpty) {
      return Center(child: Text('No replies yet.', style: textStyle));
    }
    return PostList(
      initialPosts: replies,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onPostChanged: (updatedPost) {
        setState(() {
          final index = replies.indexWhere((p) => p.id == updatedPost.id);
          if (index != -1) {
            replies[index] = updatedPost;
          }
        });
        widget.onPostChanged?.call(updatedPost);
      },
    );
  }
}