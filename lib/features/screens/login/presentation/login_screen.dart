import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/widgets/logo.dart';
import 'package:fleeds/features/components/authentication/presentation/login_form.dart';
import 'package:fleeds/features/components/authentication/presentation/signup_form.dart';

/// Login/Signup screen for the Fleeds app
class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  bool _showSignup = false;

  void _toggleForm() {
    setState(() { _showSignup = !_showSignup; });
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void initState() {
    super.initState();
    _checkExistingAuth();
  }

  /// Checks if already authenticated and navigates to the main screen if so.
  void _checkExistingAuth() {
    if (AuthService.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < kDesktopBreakpoint) {
        return _buildMobileLayout(context);
      } else {
        return _buildDesktopLayout(context);
      }
    });
  }

  /// Builds the mobile layout of the login screen, which is a single column with the logo and form.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Logo(size: kLoginLogoSizeMobile),
              const SizedBox(height: 16),
              Text(
                'Welcome to Fleeds',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _showSignup
                ? SignupForm(
                    onSignupSuccess: _goToHome,
                    onBackToLogin: _toggleForm,
                  )
                : LoginForm(
                    onLoginSuccess: _goToHome,
                    onBackToSignup: _toggleForm
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the desktop layout of the login screen, which has a two-column design with the logo on the left and the form on the right.
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              Expanded(
                child: Logo(size: kLoginLogoSizeDesktop),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to Fleeds',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _showSignup
                            ? SignupForm(
                                onSignupSuccess: _goToHome,
                                onBackToLogin: _toggleForm,
                              )
                            : LoginForm(
                                onLoginSuccess: _goToHome,
                                onBackToSignup: _toggleForm
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


