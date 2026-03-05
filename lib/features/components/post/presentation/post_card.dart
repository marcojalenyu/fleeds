import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/date_utils.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:fleeds/widgets/card.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/profile_pic.dart';

/// Widget to display a single post in a card format, used in lists and post details
class PostCard extends StatefulWidget {

  final Post post;
  final User user;
  final void Function(Post)? onPostChanged;

  const PostCard({
    super.key, 
    required this.post, 
    required this.user,
    this.onPostChanged,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  
  late final PostController _postController;
  late bool _isLiking = false;
  late bool _isLiked = false;
  late int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _postController = PostController();
    _postController.post = widget.post;
    _isLiked = widget.post.isLikedBy(AuthService.currentUser?.id ?? '');
    _likeCount = widget.post.likeCount;
  }

  /// Toggles the like status of the post for the current user, with optimistic UI update
  void _toggleLike(User? user) async {
    if (!await (AuthService.requireAuth(context))) return;
    if (user == null || _isLiking) return;
    // Optimistically update UI
    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked; 
      _likeCount += _isLiked ? 1 : -1;
    });
    final success = await _postController.toggleLike(user.id, user.username);
    if (!mounted) return;
    setState(() { _isLiking = false; });
    // If the like action in backend failed, revert the optimistic update
    if (success && _postController.post != null) {
      widget.onPostChanged?.call(_postController.post!);
    } else {
      setState(() {
        _isLiked = !_isLiked; 
        _likeCount += _isLiked ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final post = _postController.post!;
    final poster = widget.user;
    final currentUser = AuthService.currentUser;
    const textStyle = TextStyle(fontSize: 16);

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClickableProfilePic(user: poster),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Post header: Display name, username, timestamp
                Row(
                  children: [
                    Clickable(
                      onTap: () => NavigationUtils.goToProfile(context, poster),
                      child: Text(
                        poster.displayName,
                        style: textStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('@${poster.username}', style: textStyle.copyWith(color: Colors.grey[600])),
                    const SizedBox(width: 6),
                    Text('· ${DisplayDateUtils.displayTimeAgo(post.createdAt)}', style: textStyle.copyWith(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 2),
                SelectableText(post.content, style: textStyle),
                const SizedBox(height: 4),
                /// Action buttons: Reply and Like
                Row(
                  children: [
                    Clickable(
                      onTap: () => NavigationUtils.goToPost(context, post: post, user: poster),
                      child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    Text('${post.replyCount}', style: textStyle.copyWith(color: Colors.grey[600])),
                    const SizedBox(width: 32),
                    Clickable(
                      onTap: _isLiking ? null : () => _toggleLike(currentUser),
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isLiked ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$_likeCount', style: textStyle.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


