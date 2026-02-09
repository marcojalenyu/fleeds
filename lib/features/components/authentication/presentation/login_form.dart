import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';

/// Login form widget used in the login screen, allowing users to enter their credentials and log in.
class LoginForm extends StatefulWidget {
  
  final VoidCallback onBackToSignup;
  final VoidCallback onLoginSuccess;
  
  const LoginForm({
    super.key, 
    required this.onBackToSignup, 
    required this.onLoginSuccess
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

/// State class for the LoginForm, managing the input fields, error messages, and login logic. It interacts with the AuthService to perform authentication and handles navigation on successful login.
class _LoginFormState extends State<LoginForm> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  /// Handles the login process by validating input, 
  /// calling the AuthService, and 
  /// updating the UI based on the result.
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter both username and password.';
      });
      return;
    }
    setState(() { _error = null; _isLoading = true; });
    final success = await AuthService.login(username, password);
    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _error = 'Invalid username or password.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 16),
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
          onPressed: _isLoading ? null : _login,
          child: _isLoading 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Login'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onBackToSignup,
          child: const Text('Don\'t have an account? Sign up'),
        ),
      ],
    );
  }
}


