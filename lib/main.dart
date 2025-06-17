import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/screens/dashboard_screen.dart';
import 'features/auth/presentation/screens/registration.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/role_success_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/user/presentation/screens/user_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final _router = GoRouter(
    initialLocation: '/', // Start with splash screen
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/auth/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/select-role', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/role-success', builder: (context, state) => const RoleSuccessScreen()),
      GoRoute(path: '/user/profile', builder: (context, state) => const UserProfileScreen()),
      GoRoute(
        path: '/user/dashboard',
        builder: (context, state) {
          final role = state.extra as String?; // Retrieve role from extra
          return role != null ? DashboardScreen(role: role) : const DashboardScreen(role: 'Unknown');
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InternLog',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A237E),
          secondary: Color(0xFF00BCD4),
          surface: Color(0xFFF5F5F5),
          onSurface: Color(0xFF333333),
          error: Color(0xFFD32F2F),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}