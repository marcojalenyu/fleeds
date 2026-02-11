import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/services/post_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:flutter/material.dart';

/// Controller to manage post data and interactions
class PostController extends ChangeNotifier {
  final PostService _service;
  
  bool isLoading = false;
  String? error;
  Post? post;
  DocumentSnapshot? _lastDocument;
  bool hasMore = true;

  PostController({PostService? service})
      : _service = service ?? const PostService();

  /// Resets pagination state for fetching posts
  void resetPagination() {
    _lastDocument = null;
    hasMore = true;
  }

  /// Sets loading state and clears errors
  void startLoading() {
    isLoading = true;
    error = null;
    notifyListeners();
  }

  /// Ends loading state
  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPost(String postId) async {
    startLoading();
    try {
      post = await _service.fetchPost(postId);
    } catch (e) {
      error = 'Failed to fetch post: $e';
    }
    endLoading();
  }

  Future<List<Post>> fetchPosts({
    List<String> keywords = const [],
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) resetPagination();
    if (!hasMore) return [];
    startLoading();
    try {
      final result = await _service.fetchPostsByKeyword(
        keywords: keywords, 
        limit: limit, 
        startAfter: _lastDocument
      );
      _lastDocument = result.lastDoc;
      final posts = result.posts;
      if (posts.length < limit) hasMore = false;
      endLoading();
      return posts;
    } catch (e) {
      error = 'Failed to fetch posts: $e';
      endLoading();
      return [];
    }
  }

  Future<List<Post>> fetchPostsByUser({
    required String userId,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) resetPagination();
    if (!hasMore) return [];
    startLoading();
    try {
      final result = await _service.fetchPostsByUser(
        userId : userId,
        limit: limit,
        startAfter: _lastDocument
      );
      _lastDocument = result.lastDoc;
      final posts = result.posts;
      if (posts.length < limit) hasMore = false;
      endLoading();
      return posts;
    } catch (e) {
      error = 'Failed to fetch user posts: $e';
      endLoading();
      return [];
    }
  }

  Future<List<Post>> fetchPostsLikedByUser({
    required String userId,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) resetPagination();
    if (!hasMore) return [];
    startLoading();
    try {
      final result = await _service.fetchPostsLikedByUser(
        userId: userId,
        limit: limit,
        startAfter: _lastDocument
      );
      _lastDocument = result.lastDoc;
      final posts = result.posts;
      if (posts.length < limit) hasMore = false;
      endLoading();
      return posts;
    } catch (e) {
      error = 'Failed to fetch liked posts: $e';
      endLoading();
      return [];
    }
  }

  Future<List<Post>> fetchReplies({
    required String postId,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) resetPagination();
    if (!hasMore) return [];
    startLoading();
    try {
      final result = await _service.fetchReplies(
        postId: postId,
        limit: limit,
        startAfter: _lastDocument
      );
      _lastDocument = result.lastDoc;
      final replies = result.posts;
      if (replies.length < limit) hasMore = false;
      endLoading();
      return replies;
    } catch (e) {
      error = 'Failed to fetch replies: $e';
      endLoading();
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
    startLoading();
    try {
      final replyId = await _service.addReply(content: content, authorId: authorId, repliedToPostId: parentPostId);
      if (replyId != null && post != null && post!.id == parentPostId) {
        post = post!.addReply(replyId);
      }
      endLoading();
      return replyId;
    } catch (e) {
      error = 'Failed to reply to post: $e';
      endLoading();
      return null;
    }
  }
}