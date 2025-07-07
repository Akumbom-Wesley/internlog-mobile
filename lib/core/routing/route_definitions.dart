import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/features/student/presentation/screens/downloads_screen.dart';
import 'package:internlog/features/auth/presentation/screens/dashboard_screen.dart';
import 'package:internlog/features/auth/presentation/screens/registration.dart';
import 'package:internlog/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:internlog/features/auth/presentation/screens/role_success_screen.dart';
import 'package:internlog/features/auth/presentation/screens/splash_screen.dart';
import 'package:internlog/features/auth/presentation/screens/login_screen.dart';
import 'package:internlog/features/auth/presentation/screens/logout_screen.dart';
import 'package:internlog/features/student/presentation/screens/log_entries_screen.dart';
import 'package:internlog/features/student/presentation/screens/logentry_detail_screen.dart';
import 'package:internlog/features/student/presentation/screens/student_dashboard.dart';
import 'package:internlog/features/student/presentation/screens/weekly_logs.dart';
import 'package:internlog/features/user/presentation/screens/user_profile_screen.dart';

class RouteDefinitions {
  static List<GoRoute> get routes => [
    // Auth Routes
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
      path: '/auth/logout',
      builder: (context, state) => const LogoutScreen(),
    ),

    // User Routes
    GoRoute(
      path: '/user/profile',
      builder: (context, state) => const UserProfileScreen(),
    ),
    GoRoute(
      path: '/user/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/user/downloads',
      builder: (context, state) => const DownloadsScreen(role:"student"),
    ),

    // Logbook Routes
    GoRoute(
      path: '/user/logbook',
      builder: (context, state) => const WeeklyLogsScreen(role: "student"),
    ),
    GoRoute(
      path: '/user/logbook/week/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return LogEntriesScreen(weeklyLogId: id);
      },
    ),
    GoRoute(
      path: '/user/logbook/entry/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return LogEntryDetailScreen(entryId: id);
      },
    ),

    GoRoute(
      path: '/user/students',
      builder: (context, state) => const StudentDashboard(role: '',),
    ),

    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return UserProfileScreen(userId: id);
      },
    ),
    // Feature Routes (Placeholder)
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
  ];
}