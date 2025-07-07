import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';

import 'core/routing/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InternLog',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.info,
          surface: const Color(0xFFF5F5F5),
          onSurface: AppColors.primary.shade900,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.headline,
          displayMedium: AppTypography.headerTitle,
          displaySmall: AppTypography.headerSubtitle,
          headlineMedium: AppTypography.subtitle,
          bodyLarge: AppTypography.body,
          bodyMedium: AppTypography.caption,
          labelLarge: AppTypography.button,
          bodySmall: AppTypography.status,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppWidgetStyles.elevatedButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppWidgetStyles.outlinedButton,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: AppWidgetStyles.inputDecoration.border,
          labelStyle: AppWidgetStyles.inputDecoration.labelStyle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.itemPadding,
            vertical: AppConstants.itemPadding / 2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: AppDecorations.cardShape,
          color: AppDecorations.card.color,
          margin: const EdgeInsets.all(AppConstants.itemSpacing),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          titleTextStyle: AppTypography.headerTitle,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.2),
        ),
      ),
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}