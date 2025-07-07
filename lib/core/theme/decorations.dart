import 'package:flutter/material.dart';
import 'colors.dart';

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 2),
  );

  static BoxDecoration headerCard = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );


  static BoxDecoration itemCard = BoxDecoration(
    color: AppColors.primary.withOpacity(0.03),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
  );

  static BoxDecoration emptyCard = BoxDecoration(
    color: AppColors.error.withOpacity(0.03),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.error.withOpacity(0.1), width: 1),
  );

  static BoxDecoration iconContainer = BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  );

  static BoxDecoration statusContainer = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration errorContainer = BoxDecoration(
    color: AppColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.error.withOpacity(0.5), width: 1),
  );

  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary.withOpacity(0.02), Colors.white],
  );
}