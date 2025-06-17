import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              children: [
                _buildPage(context, 'Welcome to InternLog', 'Manage your internship logs easily.'),
                _buildPage(context, 'Track Skills', 'Monitor your skill growth with AI insights.'),
                _buildPage(context, 'Secure Validation', 'Get supervisor approval with digital signatures.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, String title, String description) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}