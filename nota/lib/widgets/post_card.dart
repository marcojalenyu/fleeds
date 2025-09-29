import 'package:flutter/material.dart';
import 'package:nota/core/utils/date_utils.dart';
import 'package:nota/core/utils/navigation_utils.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/data/services/post_service.dart';
import 'package:nota/widgets/card.dart';
import 'package:nota/widgets/clickable.dart';
import 'package:nota/widgets/profile_pic.dart';

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

    bool isLiking = false;

    void _toggleLikeBy(User? user) async {
      if (user == null) return;
      setState(() {
          isLiking = true;
      });
      await PostService.likePost(widget.post.id, user.id);
      setState(() {
          isLiking = false;
      });
      widget.onPostChanged?.call(widget.post);
    }

    @override
    Widget build(BuildContext context) {
      final post = widget.post;
      final user = widget.user;
      final currentUser = AuthService.currentUser;
      const textStyle = TextStyle(fontSize: 16);

      return Clickable( 
        onTap: () => goToPost(context, post: post, user: user),
        hoverOpacity: false,
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
                              onTap: () {

                              },
                              child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}', style: textStyle.copyWith(color: Colors.grey[600])),
                          const SizedBox(width: 32),
                          Clickable(
                              onTap: () {
                                  if (!isLiking) {
                                      _toggleLikeBy(currentUser);
                                  }
                              },
                              child: Icon(
                                  post.likedBy(currentUser!.id) ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: post.likedBy(currentUser.id) ? Colors.red : Colors.grey[600],
                              ),
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likeCount}', style: textStyle.copyWith(color: Colors.grey[600])),
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