import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DioClient _dioClient = DioClient();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Minimum splash delay

    if (!mounted) return;

    try {
      // Check if user has a stored token
      final isLoggedIn = await _dioClient.isLoggedIn();

      if (isLoggedIn) {
        // Try to get current user to verify token is still valid
        final userData = await _dioClient.getCurrentUser();
        final role = userData['role'];

        if (role == 'user' || role == null) {
          context.go('/auth/select-role');
        } else {
          context.go('/user/dashboard', extra: role);
        }
      } else {
        // No token or token is invalid, go to login
        context.go('/auth/login');
      }
    } catch (e) {
      // Error occurred (likely invalid token), go to login
      print('Auth check failed: $e');
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.app_registration, size: 100, color: Color(0xFF1A237E)),
            const SizedBox(height: 20),
            Text(
              'InternLog',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}