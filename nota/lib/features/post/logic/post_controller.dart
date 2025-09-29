import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/services/post_service.dart';

class PostController extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  late Post post;

  Future<void> fetchPost(String postId) async {
    isLoading = true;
    notifyListeners();

    try {
      post = await PostService.fetchPost(postId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Failed to fetch post: $e';
      isLoading = false;
      notifyListeners();
    }
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

  Future<bool> addPost(String userId, String content) async {
    if (content.isEmpty) {
      error = 'Content cannot be empty.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      await PostService.addPost(userId, content);
      isLoading = false;
      notifyListeners();
      return true;
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
      await PostService.likePost(postId, userId);
      isLoading = false;
      notifyListeners();
      return true;
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

  Future<bool> replyToPost(String postId, String userId, String content) async {
    if (content.isEmpty) {
      error = 'Content cannot be empty.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      await PostService.addReply(userId, content, postId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Failed to reply to post: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}