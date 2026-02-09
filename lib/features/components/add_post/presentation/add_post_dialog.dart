import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/add_post/logic/add_post_controller.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/widgets/profile_pic.dart';

/// Dialog for adding a new post. It includes a text field for post content and displays the current user's info.
class AddPostDialog extends StatefulWidget {
  final User user;
  final VoidCallback? onPostAdded;
  
  const AddPostDialog({
    super.key, 
    required this.user, 
    this.onPostAdded,
  });

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

/// State for AddPostDialog, responsible for handling user input and managing the post submission process.
class _AddPostDialogState extends State<AddPostDialog> {

  final _contentController = TextEditingController();
  final _addPostController = AddPostController();
  bool _isPosting = false;
  String? _errorMessage;

  static const _maxContentLength = 128;
  static const _textStyle = TextStyle(fontSize: 16);

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// Handles the post submission process, including validation and providing user feedback.
  Future<void> _addPost() async {
    final content = _contentController.text;
    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });
    final success = await _addPostController.addPost(content, widget.user.id);
    if (!mounted) return;
    if (success != null) {
      widget.onPostAdded?.call();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isPosting = false;
        _errorMessage = _addPostController.error ?? 'Failed to add post';
      });
    }
  }

  /// Builds the UI of the dialog, including user info, content field, and action buttons.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserInfo(),
              const SizedBox(height: 16),
              _buildContentField(),
              _buildErrorMessage(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the user info section at the top of the dialog, showing the profile picture and display name.
  Widget _buildUserInfo() {
    return Row(
      children: [
        ProfilePic(user: widget.user, size: 24.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.displayName,
                style: _textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '@${widget.user.username}',
                style: _textStyle.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the text field for entering post content, with character limit and styling.
  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      autofocus: true,
      maxLines: 4,
      minLines: 4,
      maxLength: _maxContentLength,
      decoration: InputDecoration(
        hintText: "What's on your mind?",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12, 
          horizontal: 12,
        ),
      ),
      style: _textStyle,
    );
  }

  /// Builds the Error Message display
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 12.0),
      );
  }

  /// Builds the Cancel and Post buttons
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isPosting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isPosting ? null : _addPost,
          child: _isPosting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
}