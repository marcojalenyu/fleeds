import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/profile/presentation/profile.dart';
import 'package:flutter/material.dart';

class ProfileEditDialog extends StatefulWidget {
  final User user;
  const ProfileEditDialog({super.key, required this.user});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName.isNotEmpty ? widget.user.displayName : '',
    );
    _bioController = TextEditingController(
      text: widget.user.bio.isNotEmpty ? widget.user.bio : '',
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final user = widget.user;
    const inputTextStyle = TextStyle(fontSize: 14);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(maxWidth: 400),
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar-style header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final newBio = _bioController.text.trim();
                      final newDisplayName = _displayNameController.text.trim();
                      if (newBio == widget.user.bio && newDisplayName == widget.user.displayName) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop({
                          'bio': newBio,
                          'displayName': newDisplayName,
                        });
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
            // Content
            Column(
              children: [
                ProfileHeader(user: user, bannerHeight: 80, profilePicSize: 32),
                const SizedBox(height: 42),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: const TextStyle(fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: inputTextStyle,
                        maxLength: 16,
                      ),
                      TextField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: const TextStyle(fontSize: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: inputTextStyle,
                        maxLines: null,
                        maxLength: 64,
                      ),
                      const SizedBox(height: 24),
                    ]
                  )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


