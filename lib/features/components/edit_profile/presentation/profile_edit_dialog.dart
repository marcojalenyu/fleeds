import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/edit_profile/presentation/avatar_edit_dialog.dart';
import 'package:fleeds/features/components/edit_profile/presentation/banner_edit_dialog.dart';
import 'package:fleeds/features/components/profile/presentation/profile.dart';
import 'package:fleeds/widgets/dialog_header.dart';
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
  late String? _selectedAvatarUrl;
  late String? _selectedAvatarColor;
  late String? _selectedAvatarBgColor;
  late String? _selectedBannerUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName.isNotEmpty ? widget.user.displayName : '',
    );
    _bioController = TextEditingController(
      text: widget.user.bio.isNotEmpty ? widget.user.bio : '',
    );
    _selectedAvatarUrl = widget.user.avatarUrl;
    _selectedAvatarColor = widget.user.avatarColor;
    _selectedAvatarBgColor = widget.user.avatarBgColor;
    _selectedBannerUrl = widget.user.bannerUrl;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  User get _previewUser => widget.user.copyWith(
    displayName: _displayNameController.text.trim(),
    bio: _bioController.text.trim(),
    avatarUrl: _selectedAvatarUrl ?? '',
    avatarColor: _selectedAvatarColor ?? '',
    avatarBgColor: _selectedAvatarBgColor ?? '',
    bannerUrl: _selectedBannerUrl ?? '',
  );

  /// Opens a dialog to customize avatar, allowing the user to select a new avatar URL or colors.
  Future<void> _customizeAvatar() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AvatarEditDialog(
        username: widget.user.username,
        currentAvatarUrl: _selectedAvatarUrl,
        currentAvatarColor: _selectedAvatarColor,
        currentAvatarBgColor: _selectedAvatarBgColor,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAvatarUrl = result['avatarUrl'];
        _selectedAvatarColor = result['avatarColor'];
        _selectedAvatarBgColor = result['avatarBgColor'];
      });
    }
  }

  /// Opens a dialog to customize banner, allowing the user to select a new banner URL.
  Future<void> _customizeBanner() async {
    final result = await showDialog(
      context: context,
      builder: (context) => BannerEditDialog(
        currentBannerUrl: _selectedBannerUrl,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedBannerUrl = result;
      });
    }
  }

  bool _hasChanges() {
    return _displayNameController.text.trim() != widget.user.displayName ||
           _bioController.text.trim() != widget.user.bio ||
           _selectedAvatarUrl != widget.user.avatarUrl ||
           _selectedAvatarColor != widget.user.avatarColor ||
           _selectedAvatarBgColor != widget.user.avatarBgColor ||
           _selectedBannerUrl != widget.user.bannerUrl;
  }

  @override
  Widget build(BuildContext context) {
    
    const inputTextStyle = TextStyle(fontSize: 14);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: BoxConstraints(maxWidth: 450),
      child: Container(
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
            DialogHeader(
              title: 'Edit Profile',
              actionText: 'Save',
              onActionPressed: () {
                if (!_hasChanges()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop({
                    'bio': _bioController.text.trim(),
                    'displayName': _displayNameController.text.trim(),
                    'avatarUrl': _selectedAvatarUrl,
                    'avatarColor': _selectedAvatarColor,
                    'avatarBgColor': _selectedAvatarBgColor,
                    'bannerUrl': _selectedBannerUrl,
                  });
                }
              },
            ),
            // Edit Fields
            Column(
              children: [
                ProfileHeader(
                  user: _previewUser, 
                  bannerHeight: 80, 
                  profilePicSize: 32,
                  onAvatarEdit: _customizeAvatar,
                  onBannerEdit: _customizeBanner,
                ),
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
                      const SizedBox(height: 36),
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


