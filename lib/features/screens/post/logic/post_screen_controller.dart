import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:flutter/material.dart';

class PostScreenController extends ChangeNotifier {
  final PostController _postController;
  final UserService _userService;

  PostScreenController({
    PostController? postController,
    UserService? userService,
  })  : _postController = postController ?? PostController(),
        _userService = userService ?? UserService();

  // Loading states
  bool _isLoading = true;
  bool _isLoadingReplies = false;
  bool _isLiking = false;

  // Data
  Post? _post;
  User? _author;
  Post? _parentPost;
  User? _parentPostAuthor;
  List<Post> _replies = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingReplies => _isLoadingReplies;
  bool get isLiking => _isLiking;
  Post? get post => _post;
  User? get author => _author;
  Post? get parentPost => _parentPost;
  User? get parentPostAuthor => _parentPostAuthor;
  List<Post> get replies => _replies;
  String? get error => _postController.error;

  bool isLikedBy(String userId) => _post?.isLikedBy(userId) ?? false;
  int get likeCount => _post?.likeCount ?? 0;
  int get replyCount => _post?.replyCount ?? 0;

  void initializeWithPost(Post post, User user) {
    _post = post;
    _postController.post = post;
    _author = user;
    _isLoading = false;
    notifyListeners();
    _loadParentPost();
    _loadReplies();
  }

  Future<void> loadPost(String postId) async {
    _isLoading = true;
    notifyListeners();

    await _postController.fetchPost(postId);
    _post = _postController.post;

    if (_post != null) {
      _author = await _userService.fetchUser(_post!.authorId);
      await _loadParentPost();
      await _loadReplies();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load parent post if this is a reply
  Future<void> _loadParentPost() async {
    if (_post == null || !_post!.isReply) return;

    try {
      final parentController = PostController();
      await parentController.fetchPost(_post!.repliedToPostId);
      _parentPost = parentController.post;

      if (_parentPost != null) {
        _parentPostAuthor = await _userService.fetchUser(_parentPost!.authorId);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail if parent post cannot be loaded
    }
  }

  Future<void> _loadReplies() async {
    if (_post == null) return;

    _isLoadingReplies = true;
    notifyListeners();

    _replies = await _postController.fetchReplies(
      postId: _post!.id,
      refresh: true,
    );

    _isLoadingReplies = false;
    notifyListeners();
  }

  Future<bool> toggleLike(String userId) async {
    if (_post == null || _isLiking) return false;

    _isLiking = true;
    // Optimistic update
    _post = _post!.toggleLike(userId);
    notifyListeners();

    final success = await _postController.toggleLike(userId);

    _isLiking = false;
    if (success) {
      _post = _postController.post;
    } else {
      // Rollback on failure
      _post = _post!.toggleLike(userId);
    }
    notifyListeners();

    return success;
  }

  Future<String?> replyToPost(String content, String authorId) async {    
    final replyId = await _postController.replyToPost(
      content,
      authorId,
      _post!.id,
    );
    if (replyId != null) {
      print(_postController.post);
      _post = _postController.post;
      await _loadReplies();
      notifyListeners();
    }

    return replyId;
  }

  void updateReply(Post updatedPost) {
    final index = _replies.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _replies[index] = updatedPost;
      notifyListeners();
    }
  }

  Future<void> refresh(String postId) async {
    await loadPost(postId);
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}