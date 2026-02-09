import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:flutter/material.dart';

/// Controller for managing the state of the HomeScreen, including fetching and refreshing posts.
class HomeController extends ChangeNotifier {

  final PostController _postController;
  
  List<Post> posts = [];
  bool isLoading = false;
  String? error;

  HomeController({PostController? postController})
      : _postController = postController ?? PostController();

  /// Fetches posts with optional keyword filtering.
  Future<void> fetchPosts({List<String> keywords = const []}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      posts = await _postController.fetchPosts(keywords: keywords);
    } catch (e) {
      error = 'Failed to fetch posts: $e';
      posts = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /// Refreshes the posts list.
  Future<void> refreshPosts({List<String> keywords = const []}) async {
    await fetchPosts(keywords: keywords);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}