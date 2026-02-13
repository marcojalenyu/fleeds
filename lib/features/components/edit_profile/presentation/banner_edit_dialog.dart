import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/dialog_header.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/profile_images.dart';

class BannerEditDialog extends StatefulWidget {
  final String? currentBannerUrl;

  const BannerEditDialog({
    super.key,
    required this.currentBannerUrl,
  });

  @override
  State<BannerEditDialog> createState() => _BannerEditDialogState();
}

class _BannerEditDialogState extends State<BannerEditDialog> {
  late String? _selectedBannerUrl;

  @override
  void initState() {
    super.initState();
    _selectedBannerUrl = widget.currentBannerUrl;
  }

  bool get _isNone => _selectedBannerUrl == null || _selectedBannerUrl!.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        child: Column(
          spacing: 16.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: 'Select Banner',
              actionText: 'Save',
              onActionPressed: () {
                Navigator.of(context).pop(_selectedBannerUrl);
              },
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 16 / 9,
                ),
                itemCount: ProfileImages.bannerPics.length + 1, // +1 for None
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // None option
                    return Clickable(
                      onTap: () { setState(() { _selectedBannerUrl = null; }); },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isNone ? primaryColor : Colors.grey[300]!,
                            width: _isNone ? 3 : 1,
                          ),
                          color: Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            'None',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Banner options
                  final bannerPath = ProfileImages.bannerPics[index - 1];
                  final isSelected = bannerPath == _selectedBannerUrl;

                  return Clickable(
                    onTap: () { setState(() { _selectedBannerUrl = bannerPath; }); },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        child: Image.asset(
                          bannerPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}