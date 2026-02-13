import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/profile_images.dart';
import 'package:fleeds/widgets/profile_pic.dart';
import 'package:fleeds/domain/models/user.dart';

class AvatarEditDialog extends StatefulWidget {
  final String? currentAvatarUrl;
  final String? currentAvatarColor;
  final String? currentAvatarBgColor;
  final String username;

  const AvatarEditDialog({
    super.key,
    required this.currentAvatarUrl,
    required this.currentAvatarColor,
    required this.currentAvatarBgColor,
    required this.username,
  });

  @override
  State<AvatarEditDialog> createState() => _AvatarEditDialogState();
}

class _AvatarEditDialogState extends State<AvatarEditDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String? _selectedAvatarUrl;
  late String? _selectedAvatarColor;
  late String? _selectedAvatarBgColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedAvatarUrl = widget.currentAvatarUrl;
    _selectedAvatarColor = widget.currentAvatarColor;
    _selectedAvatarBgColor = widget.currentAvatarBgColor;
    if (_isDefault) {
      _tabController.index = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isDefault => _selectedAvatarUrl == null || _selectedAvatarUrl!.isEmpty;

  String _colorToString(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  BoxDecoration _selectionBorder(bool isSelected) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? primaryColor : Colors.grey[300]!,
        width: isSelected ? 3 : 1,
      ),
    );
  }

  User get _previewUser => User(
    id: '',
    username: widget.username,
    displayName: '',
    bio: '',
    avatarUrl: _selectedAvatarUrl ?? '',
    avatarColor: _selectedAvatarColor ?? '',
    avatarBgColor: _selectedAvatarBgColor ?? '',
    bannerUrl: '',
    followers: [],
    following: [],
    createdAt: DateTime.now(),
  );

  void _selectAvatar(String avatarUrl) {
    setState(() {
      _selectedAvatarUrl = avatarUrl;
      if (_selectedAvatarColor == null || _selectedAvatarColor!.isEmpty) {
        _selectedAvatarColor = _colorToString(ProfileImages.profilePicColors[0]);
      }
      if (_selectedAvatarBgColor == null || _selectedAvatarBgColor!.isEmpty) {
        _selectedAvatarBgColor = _colorToString(ProfileImages.profilePicBgColors[0]);
      }
    });
  }

  void _clearAvatar() {
    setState(() {
      _selectedAvatarUrl = '';
      _selectedAvatarColor = '';
      _selectedAvatarBgColor = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            DialogHeader(
              title: 'Customize Avatar',
              actionText: 'Save',
              onActionPressed: () {
                Navigator.of(context).pop({
                  'avatarUrl': _selectedAvatarUrl,
                  'avatarColor': _isDefault ? '' : _selectedAvatarColor,
                  'avatarBgColor': _isDefault ? '' : _selectedAvatarBgColor,
                });
              },
            ),
            ProfilePic(user: _previewUser, size: 48),
            TabBar(
              controller: _tabController,
              tabs: [ Tab(text: 'Avatar'), Tab(text: 'Colors')],
              onTap: (index) {
                if (index == 1 && _isDefault) _tabController.index = 0;
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: _isDefault ? NeverScrollableScrollPhysics() : null,
                children: [
                  _buildImageTab(),
                  _buildColorsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: ProfileImages.profilePics.length + 1, // +1 for "None" option
          itemBuilder: (context, index) {
            if (index == 0) {
              return Clickable(
                onTap: () => _clearAvatar(),
                child: Container(
                  decoration: _selectionBorder(_isDefault),
                  child: Center(
                    child: Icon(Icons.block, color: Colors.grey),
                  ),
                ),
              );
            }

            final avatarPath = ProfileImages.profilePics[index - 1];
            final isSelected = avatarPath == _selectedAvatarUrl;

            return Clickable(
              onTap: () => _selectAvatar(avatarPath),
              child: SizedBox.expand(
                child: Container(
                  decoration: _selectionBorder(isSelected),
                  child: ProfilePic(
                    user: _previewUser.copyWith(
                      avatarUrl: avatarPath, 
                      avatarColor: _colorToString(ProfileImages.profilePicColors[0]),
                      avatarBgColor: _colorToString(ProfileImages.profilePicBgColors[0]),
                    ),
                    noPadding: true,
                  ),
                ),
              )
            );
          },
        ),
      )
    );
  }

  Widget _buildColorsTab() {
    return Padding( 
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar color
            Text(
            'Avatar Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ProfileImages.profilePicColors.map((color) {
              final colorString = _colorToString(color);
              final isSelected = colorString == _selectedAvatarColor;

              return Clickable(
                onTap: () { setState(() { _selectedAvatarColor = colorString;}); },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: _selectionBorder(isSelected).copyWith(
                    color: color,
                    shape: BoxShape.circle
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Background color
          Text(
            'Background Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ProfileImages.profilePicBgColors.map((color) {
            final colorString = _colorToString(color);
            final isSelected = colorString == _selectedAvatarBgColor;

            return Clickable(
              onTap: () {
                setState(() {
                  _selectedAvatarBgColor = colorString;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: _selectionBorder(isSelected).copyWith(
                  color: color,
                  shape: BoxShape.circle
                ),
              ),
              );
            }).toList(),
          ),
        ],
      ),
      )
    );
  }
}