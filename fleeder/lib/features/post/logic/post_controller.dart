import 'package:flutter/material.dart';
import 'package:fleeds/data/models/post.dart';
import 'package:fleeds/data/services/post_service.dart';

class PostController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  Post? post;

  Future<void> fetchPost(String postId) async {
    isLoading = true;
    notifyListeners();

    try {
      post = await PostService.fetchPost(postId);
    } catch (e) {
      error = 'Failed to fetch post: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<List<Post>> fetchPosts({List<String> keywords = const []}) async {
    isLoading = true;
    notifyListeners();

    try {
      final posts = await PostService.fetchPosts(keywords: keywords);
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
    notifyListeners();

    try {
      final posts = await PostService.fetchPostsByUser(userId);
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
    notifyListeners();

    try {
      final posts = await PostService.fetchPostsLikedByUser(userId);
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

  Future<bool> addPost(String content, String authorId) async {
    if (content.isEmpty) {
      error = 'Content cannot be empty.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      final result = await PostService.addPost(content, authorId);
      if (result) post = post;
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      error = 'Failed to add post: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> likePost(String postId, String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final updatedLikes = await PostService.toggleLike(postId, userId);
      if (updatedLikes != null && post != null) {
        post = post!.copyWith(likes: updatedLikes, updatedAt: DateTime.now());
        isLoading = false;
        notifyListeners();
        return true;
      }
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Failed to like post: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Post>> fetchReplies(String postId) async {
    isLoading = true;
    notifyListeners();

    try {
      final replies = await PostService.fetchReplies(postId);
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

  Future<String> replyToPost(String parentPostId, String authorId, String content) async {
    if (content.isEmpty) {
      error = 'Content cannot be empty.';
      notifyListeners();
      return '';
    }
    isLoading = true;
    notifyListeners();

    try {
      final result = await PostService.addReply(parentPostId, authorId, content);
      if (result != null && post != null) {
        post = post!.addReply(result);
      }
      isLoading = false;
      notifyListeners();
      return result ?? '';
    } catch (e) {
      error = 'Failed to reply to post: $e';
      isLoading = false;
      notifyListeners();
      return '';
    }
  }
}

