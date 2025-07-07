import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/routing/route_definitions.dart';
import '../presentation/screens/error_screen.dart';
import 'auth_gard.dart';

class AppRouter {
  static final DioClient _dioClient = DioClient();
  static final AuthGuard _authGuard = AuthGuard(_dioClient);

  static late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      if (state.matchedLocation == '/') {
        return null;
      }

      final authRedirect = await _authGuard.checkAuthRedirect(context, state);
      if (authRedirect != null) {
        return authRedirect;
      }

      return await _authGuard.checkAuthGuard(context, state);
    },
    routes: RouteDefinitions.routes,
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}