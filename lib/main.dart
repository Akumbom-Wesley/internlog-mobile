import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'features/auth/presentation/screens/dashboard_screen.dart';
import 'features/auth/presentation/screens/registration.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/role_success_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/logout_screen.dart';
import 'features/student/presentation/screens/log_entries_screen.dart';
import 'features/student/presentation/screens/logentry_detail_screen.dart';
import 'features/student/presentation/screens/weekly_logs.dart';
import 'features/user/presentation/screens/user_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final DioClient _dioClient = DioClient();

  // Auth guard to check if user is authenticated
  Future<String?> _authGuard(BuildContext context, GoRouterState state) async {
    try {
      final isLoggedIn = await _dioClient.isLoggedIn();
      if (!isLoggedIn) {
        return '/auth/login';
      }

      // For protected routes, verify token is still valid
      if (_isProtectedRoute(state.matchedLocation)) {
        try {
          await _dioClient.getCurrentUser();
          return null; // User is authenticated, allow access
        } catch (e) {
          // Token is invalid, redirect to login
          return '/auth/login';
        }
      }

      return null;
    } catch (e) {
      return '/auth/login';
    }
  }

  // Check if route requires authentication
  bool _isProtectedRoute(String route) {
    final protectedRoutes = [
      '/user/dashboard',
      '/user/profile',
      '/auth/select-role',
      '/role-success',
      '/auth/logout',
      '/apply-internship',
      '/past-logbooks',
      '/pending-internships',
      '/settings',
      '/companies',
    ];
    return protectedRoutes.any((protectedRoute) => route.startsWith(protectedRoute));
  }

  // Redirect logic for authenticated users trying to access auth pages
  Future<String?> _authRedirect(BuildContext context, GoRouterState state) async {
    try {
      final isLoggedIn = await _dioClient.isLoggedIn();
      if (isLoggedIn && (state.matchedLocation == '/auth/login' || state.matchedLocation == '/auth/register')) {
        // User is logged in but trying to access login/register, check their role
        try {
          final userData = await _dioClient.getCurrentUser();
          final role = userData['role'];
          if (role == 'user' || role == null) {
            return '/auth/select-role';
          } else {
            return '/user/dashboard';
          }
        } catch (e) {
          // Token invalid, allow access to login/register
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  late final _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Handle splash screen separately
      if (state.matchedLocation == '/') {
        return null;
      }

      // Check for auth redirects first
      final authRedirect = await _authRedirect(context, state);
      if (authRedirect != null) {
        return authRedirect;
      }

      // Then check auth guard for protected routes
      return await _authGuard(context, state);
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/role-success',
        builder: (context, state) => const RoleSuccessScreen(),
      ),
      GoRoute(
        path: '/user/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/user/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/auth/logout',
        builder: (context, state) => const LogoutScreen(),
      ),
      GoRoute(
        path: '/apply-internship',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/past-logbooks',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/pending-internships',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/companies',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: '/user/logbook',
        builder: (context, state) => const WeeklyLogsScreen(),
      ),
      GoRoute(
        path: '/user/logbook/week/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return LogEntriesScreen(weeklyLogId: id);
        },
      ),
      // GoRoute(
      //   path: '/user/log-entry/:id',
      //   builder: (context, state) {
      //     final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
      //     return LogEntryDetailScreen(entryId: id);
      //   },
      // ),
      
    ],
    // Handle route errors
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
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
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}