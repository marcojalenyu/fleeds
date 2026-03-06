import 'package:fleeds/core/utils/validator.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/screens/settings/logic/settings_controller.dart';
import 'package:fleeds/widgets/card.dart';
import 'package:fleeds/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';

/// SettingsScreen displays the user's settings and preferences.
/// This includes options for changing username and password.
class SettingsScreen extends StatefulWidget {

    const SettingsScreen({super.key});

    @override
    State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

    SettingsController? _settingsController;
    bool _loading = true;
    bool _saving = false;
    bool _editingUsername = false;
    bool _editingPassword = false;
    String? _response;

    final _newUsernameController = TextEditingController();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _passwordConfirmController = TextEditingController();

    User get currentUser => _settingsController!.currentUser;
  
    @override
    void initState() {
        super.initState();
        _initSettingsController();
    }

    @override
    void dispose() {
        super.dispose();
        _settingsController?.dispose();
    }

    Future<void> _initSettingsController() async {
      _settingsController = SettingsController();
      _settingsController!.addListener(() => setState(() {}));
      setState(() => _loading = false);
    }

    Future<void> _saveUsername() async {
      final newUsername = _newUsernameController.text.trim();
      final currentPassword = _currentPasswordController.text;
      final validationError = Validators.validateUsername(newUsername);
      if (newUsername.isEmpty || currentPassword.isEmpty) {
          setState(() => _response = 'Please fill in all fields.');
          return;
      } else if (validationError != null) {
          setState(() => _response = validationError);
          return;
      } else if (newUsername == currentUser.username) {
          setState(() => _response = null);
          return;
      }
      if (!await AuthService.requireAuth(context)) return;
      setState(() => _saving = true);
      _response = await _settingsController!.updateUsername(newUsername, currentPassword);
      _currentPasswordController.clear();
      setState(() => _saving = false);
    }

    Future<void> _savePassword() async {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      final confirmPassword = _passwordConfirmController.text;
      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
          setState(() => _response = 'Please fill in all fields.');
          return;
      }
      final validationError = Validators.validatePassword(newPassword);
      if (validationError != null) {
          setState(() => _response = validationError);
          return;
      } else if (newPassword != confirmPassword) {
          setState(() => _response = 'Passwords do not match.');
          return;
      } else if (currentPassword == newPassword) {
          setState(() => _response = 'New password cannot be the same as current password.');
          return;
      }
      if (!await AuthService.requireAuth(context)) return;
      setState(() => _saving = true);
      _response = await _settingsController!.updatePassword(currentPassword, newPassword);
      if (_response == 'Password updated successfully.') {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _passwordConfirmController.clear();
      }
      setState(() => _saving = false);
    }

    /// Toggles the visibility of the edit card for username or password, 
    /// ensuring that only one can be edited at a time.
    void toggleEditCard(String field) {
        setState(() {
            if (field == 'username') {
                _editingUsername = !_editingUsername;
                _editingPassword = false;
                _newUsernameController.text = currentUser.username;
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _passwordConfirmController.clear();
                _response = null;
            } else if (field == 'password') {
                _editingPassword = !_editingPassword;
                _editingUsername = false;
                _newUsernameController.clear();
                _currentPasswordController.clear();
                _newPasswordController.clear();
                _passwordConfirmController.clear();
                _response = null;
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        if (_loading || _settingsController == null) {
            return MainScaffold(
                currentIndex: 4, 
                body: const Center(child: CircularProgressIndicator()),
            );
        }
        return MainScaffold(
            currentIndex: 4, 
            body: Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                body: SingleChildScrollView (
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16.0,
                        children: [
                            const Text('Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            /// Edit Username Card
                            CustomCard(
                                noMargin: true,
                                child: IntrinsicHeight(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4.0,
                                        children: [
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    const Text('Username:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                                    IconButton(
                                                        onPressed: () => toggleEditCard('username'),
                                                        icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                                        splashRadius: 20,
                                                        visualDensity: VisualDensity.compact,
                                                    )                                                
                                                ],
                                            ),
                                            SelectableText("@${currentUser.username}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            _editingUsername ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    const SizedBox(height: 4),
                                                    SizedBox(
                                                        width: 200,
                                                        child: TextField(
                                                            controller: _newUsernameController,
                                                            maxLength: 16,
                                                            maxLines: 1,
                                                            decoration: const InputDecoration(
                                                                labelText: 'New Username',
                                                                counterText: '',
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row (
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                            SizedBox(
                                                                width: 400,
                                                                child: TextField(
                                                                    controller: _currentPasswordController,
                                                                    maxLength: 64,
                                                                    maxLines: 1,
                                                                    obscureText: true,
                                                                    decoration: const InputDecoration(
                                                                        labelText: "Password",
                                                                        counterText: ''
                                                                    )
                                                                ),
                                                            ),
                                                        ]
                                                    ),
                                                    SizedBox(height: 8),
                                                    SelectableText(_response ?? '', style: const TextStyle(color: Colors.red)),
                                                    SizedBox(height: (_response != null) ? 12 : 0),
                                                    Center(
                                                        child: ElevatedButton(
                                                            onPressed: _saving ? null : _saveUsername,
                                                            child: _saving 
                                                            ? const SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                                )
                                                            : const Text('Save'),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                ]
                                             ) : const SizedBox.shrink(),
                                        ]
                                    )
                                ),
                            ),
                            /// Edit Password Card
                            CustomCard(
                                noMargin: true,
                                child: IntrinsicHeight(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4.0,
                                        children: [
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    const Text('Password:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                                    IconButton(
                                                        onPressed: () => toggleEditCard('password'),
                                                        icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                                        splashRadius: 20,
                                                        visualDensity: VisualDensity.compact,
                                                    ),                                                
                                                ],
                                            ),
                                            const Text("****************", style: TextStyle(fontSize: 16)),
                                            _editingPassword ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 4.0,
                                                children: [
                                                    SizedBox(
                                                        width: 400,
                                                        child: TextField(
                                                            controller: _currentPasswordController,
                                                            maxLength: 64,
                                                            maxLines: 1,
                                                            obscureText: true,
                                                            decoration: const InputDecoration(
                                                                labelText: "Current Password",
                                                                counterText: ''
                                                            )                                                                
                                                        ),
                                                    ),
                                                    SizedBox(
                                                        width: 400,
                                                        child: TextField(
                                                            controller: _newPasswordController,
                                                            maxLength: 64,
                                                            maxLines: 1,
                                                            obscureText: true,
                                                            decoration: const InputDecoration(labelText: 'New Password'),
                                                        ),
                                                    ),
                                                    SizedBox(
                                                        width: 400,
                                                        child: TextField(
                                                            controller: _passwordConfirmController,
                                                            maxLength: 64,
                                                            maxLines: 1,
                                                            obscureText: true,
                                                            decoration: const InputDecoration(
                                                                labelText: 'Confirm New Password',
                                                                counterText: ''
                                                            )
                                                        ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    SelectableText(_response ?? '', style: const TextStyle(color: Colors.red)),
                                                    SizedBox(height: (_response != null) ? 12 : 0),
                                                    Center(
                                                        child: ElevatedButton(
                                                            onPressed: _saving ? null : _savePassword,
                                                            child: _saving 
                                                            ? const SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                                )
                                                            : const Text('Save'),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 4)
                                                ]
                                            ) : const SizedBox.shrink(),
                                        ]
                                    )
                                ),
                            ),
                        ],
                    ),
                ),
            )
        );
    }
}