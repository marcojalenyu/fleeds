import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/post_service.dart';

class PostCard extends StatefulWidget {
    final Post post;
    final User user;

    const PostCard({super.key, required this.post, required this.user});
    @override
    State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

    bool isLiking = false;

    void _toggleLike() async {
        setState(() {
            isLiking = true;
        });
        await PostService.likePost(widget.post.id, widget.user.id);
        setState(() {
            isLiking = false;
        });
    }

    void _goToProfile() {
        Navigator.of(context).pushNamed('/profile', arguments: widget.user);
    }

    @override
    Widget build(BuildContext context) {
        final post = widget.post;
        final user = widget.user;
        final formattedDate = '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}, ${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}';
        const textStyle = TextStyle(fontSize: 16);
        
        return Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                    ),
                ],
            ),
            constraints: BoxConstraints(maxWidth: 600),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align avatar to top
                children: [
                    GestureDetector(
                        onTap: _goToProfile,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, right: 12),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                    ),
                    Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                                children: [
                                  GestureDetector(
                                    onTap: _goToProfile,
                                    child: Text(
                                      user.displayName,
                                      style: textStyle.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                    const SizedBox(width: 6),
                                    Text(
                                        '@${user.username}',
                                        style: textStyle.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                        '· $formattedDate',
                                        style: textStyle.copyWith(color: Colors.grey[600]),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 2),
                            Text(post.content, style: textStyle),
                            const SizedBox(height: 4),
                            Row(
                                children: [
                                    GestureDetector(
                                        onTap: () {

                                        },
                                        child: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${post.commentCount}', style: textStyle.copyWith(color: Colors.grey[600])),
                                    const SizedBox(width: 32),
                                    GestureDetector(
                                        onTap: () {
                                            if (!isLiking) {
                                                _toggleLike();
                                            }
                                        },
                                        child: Icon(
                                            post.likedBy(user.id) ? Icons.favorite : Icons.favorite_border,
                                            size: 20,
                                            color: post.likedBy(user.id) ? Colors.red : Colors.grey[600],
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
        );
    }
}