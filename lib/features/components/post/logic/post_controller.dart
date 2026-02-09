import 'package:fleeds/data/services/post_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:flutter/material.dart';

/// Controller to manage post data and interactions
class PostController extends ChangeNotifier {
  final PostService _service;
  
  bool isLoading = false;
  String? error;
  Post? post;

  PostController({PostService? service})
      : _service = service ?? const PostService();

  Future<void> fetchPost(String postId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      post = await _service.fetchPost(postId);
    } catch (e) {
      error = 'Failed to fetch post: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<List<Post>> fetchPosts({List<String> keywords = const []}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final posts = await _service.fetchPostsByKeyword(keywords: keywords);
      isLoading = false;
      notifyListeners();
      return posts;
    } catch (e) {
      error = 'Failed to fetch posts: $e';
      isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<Post>> fetchPostsByUser(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final posts = await _service.fetchPostsByUser(userId);
      isLoading = false;
      notifyListeners();
      return posts;
    } catch (e) {
      error = 'Failed to fetch user posts: $e';
      isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<Post>> fetchPostsLikedByUser(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final posts = await _service.fetchPostsLikedByUser(userId);
      isLoading = false;
      notifyListeners();
      return posts;
    } catch (e) {
      error = 'Failed to fetch liked posts: $e';
      isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<Post>> fetchReplies(String postId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final replies = await _service.fetchReplies(postId);
      isLoading = false;
      notifyListeners();
      return replies;
    } catch (e) {
      error = 'Failed to fetch replies: $e';
      isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<bool> toggleLike(String userId) async {
    if (post == null) {
      error = 'Post not loaded';
      return false;
    }
    // Optimistic update
    final optimisticPost = post!.toggleLike(userId);
    post = optimisticPost;
    notifyListeners();
    try {
      final updatedLikes = await _service.toggleLike(post!.id, userId);
      if (updatedLikes == null) {
        // Rollback on failure
        post = post!.toggleLike(userId);
        error = 'Failed to toggle like';
        notifyListeners();
        return false;
      }
      // Confirm with server state
      post = post!.copyWith(
        likes: updatedLikes,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback on error
      post = post!.toggleLike(userId);
      error = 'Error toggling like: $e';
      notifyListeners();
      return false;
    }
  }

  Future<String?> replyToPost(String content, String authorId, String parentPostId) async {
    if (content.isEmpty) {
      error = 'Content cannot be empty.';
      notifyListeners();
      return null;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final replyId = await _service.addReply(content: content, authorId: authorId, repliedToPostId: parentPostId);
      if (replyId != null && post != null && post!.id == parentPostId) {
        post = post!.addReply(replyId);
      }
      isLoading = false;
      notifyListeners();
      return replyId;
    } catch (e) {
      error = 'Failed to reply to post: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }
}