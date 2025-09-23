import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/services/post_service.dart';

class PostController extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<List<Post>> fetchPosts() async {
    isLoading = true;
    notifyListeners();

    try {
      final posts = await PostService.fetchPosts();
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

  Future<bool> addPost(String userId, String title, String content) async {
    if (title.isEmpty || content.isEmpty) {
      error = 'Title and content cannot be empty.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      await PostService.addPost(userId, title, content);
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
}