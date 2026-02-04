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
  
  late PostController _postController;
  late bool isLiking = false;
  late bool isLiked = false;
  late int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _postController = PostController();
    _postController.post = widget.post;
    isLiked = widget.post.isLikedBy(AuthService.currentUser?.id ?? '');
    likeCount = widget.post.likeCount;
  }

  void _toggleLikeBy(User? user) async {
    if (user == null || isLiking) return;

    setState(() {
      isLiking = true;
      isLiked = !isLiked; // optimistic update
      likeCount += isLiked ? 1 : -1;
    });

    final success = await _postController.toggleLike(user.id);

    setState(() {
      isLiking = false;
    });

    if (success && _postController.post != null) {
      widget.onPostChanged?.call(_postController.post!); // backend sync
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final currentUser = AuthService.currentUser;
    final post = _postController.post!;
    const textStyle = TextStyle(fontSize: 16);

    return Clickable( 
      onTap: () => goToPost(context, post: post, user: user),
      opaqueWhenHovered: false,
      child: CustomCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClickableProfilePic(user: user, imageUrl: ''),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        Clickable(
                          onTap: () => goToProfile(context, user),
                          child: Text(
                            user.displayName,
                            style: textStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('@${user.username}', style: textStyle.copyWith(color: Colors.grey[600])),
                        const SizedBox(width: 6),
                        Text('· ${DisplayDateUtils.displayTimeAgo(post.createdAt)}', style: textStyle.copyWith(color: Colors.grey[600])),
                      ],
                  ),
                  const SizedBox(height: 2),
                  Text(post.content, style: textStyle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                        Clickable(
                            onTap: () {},
                            child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text('${post.replyCount}', style: textStyle.copyWith(color: Colors.grey[600])),
                        const SizedBox(width: 32),
                        Clickable(
                            onTap: () {
                                if (!isLiking) {
                                    _toggleLikeBy(currentUser);
                                }
                            },
                            child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isLiked ? Colors.red : Colors.grey[600],
                            ),
                        ),
                        const SizedBox(width: 4),
                        Text('$likeCount', style: textStyle.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


