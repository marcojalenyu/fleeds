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
      posts = await _postController.fetchPosts(
        keywords: keywords,
        refresh: true
      );
    } catch (e) {
      error = 'Failed to fetch posts: $e';
      posts = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<List<Post>> fetchMorePosts({List<String> keywords = const []}) async {
    if (isLoading) return [];
    isLoading = true;
    notifyListeners();
    var morePosts = <Post>[];

    try {
      morePosts = await _postController.fetchPosts(keywords: keywords);
      posts.addAll(morePosts);
    } catch (e) {
      error = 'Failed to fetch more posts: $e';
    }

    isLoading = false;
    notifyListeners();
    return morePosts;
  }

  /// Refreshes the posts list.
  Future<void> refreshPosts({List<String> keywords = const []}) async {
    _postController.resetPagination();
    await fetchPosts(keywords: keywords);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}