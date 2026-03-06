import 'package:file_picker/file_picker.dart';
import 'package:fleeds/data/services/media_service.dart';
import 'package:fleeds/data/services/post_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:flutter/material.dart';

/// Controller for managing the state of adding a new post.
class AddPostController extends ChangeNotifier {
  
  final PostService _service;
  final MediaService _mediaService;
  bool isLoading = false;
  String? error;

  PlatformFile? _cachedFile;
  String? _cachedMediaUrl;

  AddPostController({PostService? service, MediaService? mediaService})
      : _service = service ?? const PostService(),
        _mediaService = mediaService ?? MediaService();

  void clearMediaCache() {
    _cachedFile = null;
    _cachedMediaUrl = null;
  }

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
  Future<String?> addPost(String content, String authorId, PlatformFile? mediaFile) async {

    String sanitizedContent = _sanitizeContent(content);

    if (!Post.isValid(sanitizedContent)) {
      error = 'Post content cannot be empty.';
      notifyListeners();
      return null;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    String? mediaUrl;
    if (mediaFile != null) {
      // Reuse cached URL if retrying with the same file
      if (identical(_cachedFile, mediaFile) && _cachedMediaUrl != null) {
        mediaUrl = _cachedMediaUrl;
      } else {
        mediaUrl = await _mediaService.uploadMedia(mediaFile.bytes!, mediaFile.name);
        if (mediaUrl == null) {
          error = 'Your media file may be too large or of an unsupported format. Please try again with a different file.';
          isLoading = false;
          notifyListeners();
          return null;
        }
        _cachedFile = mediaFile;
        _cachedMediaUrl = mediaUrl;
      }
    }
    
    try {
      final success = await _service.addPost(
        content: sanitizedContent, 
        authorId: authorId,
        mediaUrl: mediaUrl,
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