import 'package:flutter/material.dart';
import 'colors.dart';
import 'constants.dart';
import 'typography.dart';


class AppWidgetStyles {
  static ButtonStyle elevatedButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTypography.button,
  );

  static ButtonStyle successButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.approved,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTypography.button,
  );

  static ButtonStyle errorButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.rejected,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTypography.button,
  );

  static InputDecoration inputDecoration = InputDecoration(
    labelStyle: AppTypography.subtitle,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 2),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: AppTypography.button,
  );

  static CircleAvatar headerAvatar({required String text, double radius = 35}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(0.2),
      child: Text(
        text.isNotEmpty ? text[0].toUpperCase() : '?',
        style: AppTypography.headerTitle.copyWith(fontSize: 24),
      ),
    );
  }
}