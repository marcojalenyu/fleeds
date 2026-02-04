import 'package:flutter/material.dart';
import 'package:fleeds/core/constants/constants.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/widgets/logo.dart';
import 'package:fleeds/features/components/login/presentation/login_form.dart';
import 'package:fleeds/features/components/signup/presentation/signup_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSignup = false;

  void _toggleForm() {
    setState(() {
      _showSignup = !_showSignup;
    });
  }

  void _onSignupSuccess() {
    setState(() {
      _showSignup = false;
    });
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
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
                      onSignupSuccess: _onSignupSuccess,
                      onBackToLogin: _toggleForm,
                    )
                  : LoginForm(onSignup: _toggleForm),
            ],
          ),
        ),
      ),
    );
  }

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
                                onSignupSuccess: _onSignupSuccess,
                                onBackToLogin: _toggleForm,
                              )
                            : LoginForm(onSignup: _toggleForm),
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


