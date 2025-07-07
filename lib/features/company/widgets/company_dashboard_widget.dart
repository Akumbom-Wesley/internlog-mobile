import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';
import 'internship_item.dart';
import 'internship_request_item.dart';

class CompanyDashboardWidgets {
  static Widget buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.headerCard,
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.business, color: Colors.white, size: AppConstants.iconSizeLarge),
          ),
          const SizedBox(width: AppConstants.sectionSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Dashboard',
                  style: AppTypography.headerTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your internships and requests',
                  style: AppTypography.headerSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
      padding: const EdgeInsets.all(AppConstants.itemPadding),
      decoration: AppDecorations.itemCard,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.iconPadding),
            decoration: AppDecorations.iconContainer.copyWith(
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(icon, color: iconColor, size: AppConstants.iconSizeLarge),
          ),
          const SizedBox(width: AppConstants.sectionSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not available',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.emptyCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: AppColors.error.withOpacity(0.6), size: AppConstants.iconSizeLarge),
          const SizedBox(width: AppConstants.itemSpacing),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.error.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.iconPadding),
          decoration: AppDecorations.iconContainer,
          child: Icon(icon, color: AppColors.primary, size: AppConstants.iconSizeLarge),
        ),
        const SizedBox(width: AppConstants.itemSpacing),
        Text(
          title,
          style: AppTypography.headline,
        ),
      ],
    );
  }

  static Widget buildActiveInternshipsSection({
    required List<dynamic> activeInternships,
    required VoidCallback onViewAllPressed,
    required String Function(String?) formatDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('Active Internships', Icons.work_outline),
          const SizedBox(height: AppConstants.itemSpacing),
          activeInternships.isEmpty
              ? buildEmptyCard('No active internships')
              : Column(
            children: activeInternships
                .sublist(0, activeInternships.length > 3 ? 3 : activeInternships.length)
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final internship = entry.value;
              return InternshipItem(
                internship: internship,
                iconColorIndex: index,
                formatDate: formatDate,
              );
            }).toList(),
          ),
          if (activeInternships.isNotEmpty) ...[
            const SizedBox(height: AppConstants.itemSpacing),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewAllPressed,
                child: Text(
                  'View All (${activeInternships.length})',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildPendingRequestsSection({
    required List<dynamic> pendingRequests,
    required VoidCallback onViewAllPressed,
    required VoidCallback onRequestProcessed,
    required Future<List<dynamic>> Function(String) getSupervisors,
    required Future<void> Function(int, int) approveRequest,
    required Future<void> Function(int) rejectRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('Pending Requests', Icons.pending_actions),
          const SizedBox(height: AppConstants.itemSpacing),
          pendingRequests.isEmpty
              ? buildEmptyCard('No pending requests')
              : Column(
            children: pendingRequests
                .sublist(0, pendingRequests.length > 3 ? 3 : pendingRequests.length)
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final request = entry.value;
              return InternshipRequestItem(
                request: request,
                iconColorIndex: index,
                onRequestProcessed: onRequestProcessed,
                getSupervisors: getSupervisors,
                approveRequest: approveRequest,
                rejectRequest: rejectRequest,
              );
            }).toList(),
          ),
          if (pendingRequests.isNotEmpty) ...[
            const SizedBox(height: AppConstants.itemSpacing),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewAllPressed,
                child: Text(
                  'View All (${pendingRequests.length})',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}