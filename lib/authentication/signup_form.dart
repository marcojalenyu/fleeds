import 'package:fleeds/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';

/// Signup form widget used in the login screen, allowing users to enter their details and create a new account.
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

/// State class for the SignupForm, managing the input fields, error messages, and signup logic. It interacts with the AuthService to perform user registration and handles navigation on successful signup.
class _SignupFormState extends State<SignupForm> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  bool get _isFormFilled {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _displayNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  /// Handles the signup process when the user presses the "Sign Up" button. 
  /// It validates the input fields, 
  /// displays error messages if validation fails, and 
  /// calls the AuthService to create a new user account
  void _signup() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final displayName = _displayNameController.text;
    final email = _emailController.text;
    
    if (!_isFormFilled) {
      setState(() {
        _error = 'Please fill in all fields.';
      });
      return;
    }

    String ? usernameError = Validators.validateUsername(username);
    String ? displayNameError = Validators.validateDisplayName(displayName);
    String ? emailError = Validators.validateEmail(email);
    String ? passwordError = Validators.validatePassword(password);

    if (usernameError != null || 
        displayNameError != null || 
        emailError != null || 
        passwordError != null) 
    {
      setState(() {
        _error = usernameError ?? 
          displayNameError ?? 
          emailError ?? 
          passwordError;
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
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
        _error = 'Username or email already exists.';
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
          maxLength: 254,
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          maxLength: 64,
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
          onPressed: _isLoading ? null : _signup,
          child: _isLoading 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Sign Up'),
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


