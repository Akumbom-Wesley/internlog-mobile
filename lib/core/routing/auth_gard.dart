import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';

class AuthGuard {
  final DioClient _dioClient;

  AuthGuard(this._dioClient);

  Future<String?> checkAuthGuard(BuildContext context, GoRouterState state) async {
    try {
      final isLoggedIn = await _dioClient.isLoggedIn();
      if (!isLoggedIn) {
        return '/auth/login';
      }

      if (_isProtectedRoute(state.matchedLocation)) {
        try {
          await _dioClient.getCurrentUser();
          return null;
        } catch (e) {
          return '/auth/login';
        }
      }

      return null;
    } catch (e) {
      return '/auth/login';
    }
  }

  Future<String?> checkAuthRedirect(BuildContext context, GoRouterState state) async {
    try {
      final isLoggedIn = await _dioClient.isLoggedIn();
      if (isLoggedIn && (state.matchedLocation == '/auth/login' || state.matchedLocation == '/auth/register')) {
        try {
          final userData = await _dioClient.getCurrentUser();
          final role = userData['role'];
          if (role == 'user' || role == null) {
            return '/auth/select-role';
          } else {
            return '/user/dashboard';
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
      '/user/logbook',
      '/user/logbook/week',
      '/user/logbook/entry',
    ];
    return protectedRoutes.any((protectedRoute) => route.startsWith(protectedRoute));
  }
}