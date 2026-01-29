import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  final VoidCallback onBackToLogin;
  const SignupForm({
    super.key,
    required this.onSignupSuccess,
    required this.onBackToLogin,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _error;

  void _signup() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final displayName = _displayNameController.text;
    final email = _emailController.text;
    if (!_isFormValid) {
      setState(() {
        _error = 'Please fill in all fields.';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters long.';
      });
      return;
    }
    setState(() {
      _error = null;
    });
    final success = await AuthService.signup(
      displayName,
      username,
      email,
      password,
    );
    if (success) {
      widget.onSignupSuccess();
    } else {
      setState(() {
        _error = 'Signup failed: Username or email already exists.';
      });
    }
  }

  bool get _isFormValid {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _displayNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _displayNameController,
          decoration: const InputDecoration(labelText: 'Display Name'),
          maxLength: 16,
        ),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Unique Username'),
          maxLength: 16,
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          maxLength: 64,
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        SizedBox(height: (_error != null) ? 16 : 32),
        ElevatedButton(
          onPressed: _signup,
          child: const Text('Sign Up'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onBackToLogin,
          child: const Text('Already have an account? Log in'),
        ),
      ],
    );
  }
}

