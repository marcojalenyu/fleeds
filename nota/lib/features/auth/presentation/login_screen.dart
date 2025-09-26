import 'package:flutter/material.dart';
import 'package:nota/core/constants/constants.dart';
import 'package:nota/widgets/logo.dart';
import 'package:nota/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: 
      (context, constraints) {
        if (constraints.maxWidth < kDesktopBreakpoint) {
          return _buildMobileLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      }
    );
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
              Text('Welcome to Nota', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LoginForm(onSignup: () => _navigateToSignup(context)),
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
                        Text('Welcome to Nota', 
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        LoginForm(onSignup: () => _navigateToSignup(context)),
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