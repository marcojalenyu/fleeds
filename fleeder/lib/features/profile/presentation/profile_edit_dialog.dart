import 'package:flutter/material.dart';
import 'package:fleeds/data/models/user.dart';
import 'package:fleeds/widgets/profile_pic.dart';

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
    const textStyle = TextStyle(fontSize: 16);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(maxWidth: 400),
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(12),
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
            // User info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePic(user: user),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300 - 72 - 16,
                        child: TextField(
                          controller: _displayNameController,
                          autofocus: true,
                          maxLines: 1,
                          minLines: 1,
                          maxLength: 16,
                          decoration: InputDecoration(
                            hintText: "Display Name",
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.all(0)
                          ),
                          style: textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: textStyle.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Post content field
            TextField(
              controller: _bioController,
              autofocus: true,
              maxLines: 3,
              minLines: 3,
              maxLength: 64,
              decoration: InputDecoration(
                hintText: "Tell the world about yourself...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              style: textStyle,
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }
}

