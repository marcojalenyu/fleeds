import 'package:fleeds/data/services/post_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:flutter/material.dart';

/// Controller for managing the state of adding a new post.
class AddPostController extends ChangeNotifier {
  
  final PostService _service;
  bool isLoading = false;
  String? error;

  AddPostController({PostService? service})
      : _service = service ?? const PostService();

  /// Sanitizes post content by trimming whitespace.
  String _sanitizeContent(String content) {
    String sanitized = content
      .trim()
      .replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '')
      .replaceAll('<', '&lt;') // escape HTML
      .replaceAll('>', '&gt;')
      .replaceAll('&', '&amp;');
    
    /// Limit newlines
    int newlineCount = '\n'.allMatches(sanitized).length;
      if (newlineCount > 16) {
        int removed = 0;
        sanitized = sanitized.replaceAllMapped(RegExp(r'\n'), (match) {
          if (newlineCount - removed > 8) {
            removed++;
            return '';
          }
          return match.group(0)!;
        });
      }
  
    return sanitized;
  }

  /// Adds a new post with the given content and author ID.
  /// Returns the new post ID on success, or null on failure.
  Future<String?> addPost(String content, String authorId) async {

    String sanitizedContent = _sanitizeContent(content);

    if (!Post.isValid(sanitizedContent)) {
      error = 'Post content cannot be empty.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final success = await _service.addPost(
        content: sanitizedContent, 
        authorId: authorId
      );
      isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      error = 'Failed to add post: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }
}