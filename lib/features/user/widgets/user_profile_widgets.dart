import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/constants.dart';
import '../../../core/theme/decorations.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/widget_styles.dart';

class UserProfileWidgets {
  static Widget buildProfileHeader({
    required Map<String, dynamic> userData,
    required bool isCurrentUser,
    required BuildContext context,
  }) {
    final fullName = userData['full_name'] ?? 'Unknown User';
    final role = userData['role'] ?? 'user';
    final imageUrl = userData['image'];

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: AppConstants.sectionSpacing),
          decoration: AppDecorations.headerCard,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.cardPadding,
              AppConstants.cardPadding,
              AppConstants.cardPadding,
              AppConstants.cardPadding * 1.5,
            ),
            child: Column(
              children: [
                AppWidgetStyles.headerAvatar(
                  text: fullName,
                  radius: 50,
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  fullName,
                  style: AppTypography.headerTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.itemSpacing / 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.iconPadding * 1.5,
                    vertical: AppConstants.iconPadding,
                  ),
                  decoration: AppDecorations.statusContainer.copyWith(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Text(
                    role.replaceAll('_', ' ').toUpperCase(),
                    style: AppTypography.status.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isCurrentUser)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Image upload functionality to be implemented',
                      style: AppTypography.caption,
                    ),
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppConstants.iconPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeSmall,
                ),
              ),
            ),
          ),
        if (isCurrentUser)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Edit profile functionality to be implemented',
                      style: AppTypography.caption,
                    ),
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.iconPadding * 1.5,
                  vertical: AppConstants.iconPadding,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: AppConstants.iconSizeSmall,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: AppDecorations.cardShape,
      color: AppDecorations.card.color,
      margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headline,
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.iconPadding),
            decoration: AppDecorations.iconContainer.copyWith(
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppConstants.itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}