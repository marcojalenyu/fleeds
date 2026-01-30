import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSignup;
  const LoginForm({super.key, required this.onSignup});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter both username and password.';
      });
      return;
    }
    setState(() {
      _error = null;
    });
    final success = await AuthService.login(username, password);
    if (success) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        _error = 'Invalid username or password.';
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
          onPressed: _login,
          child: const Text('Login'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onSignup,
          child: const Text('Don\'t have an account? Sign up'),
        ),
      ],
    );
  }
}


