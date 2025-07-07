import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: Center(
          child: Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  size: AppConstants.iconSizeLarge,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  'Page Not Found',
                  style: AppTypography.headline,
                ),
                const SizedBox(height: AppConstants.itemSpacing / 2),
                Text(
                  'The page you are looking for does not exist.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                ElevatedButton(
                  style: AppWidgetStyles.elevatedButton,
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}