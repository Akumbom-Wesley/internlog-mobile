import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';

import '../../../core/theme/widget_styles.dart';

class StudentDashboardWidgets {
  static Widget buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: value.contains('\n') ? 3 : 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildWeeklyLogCard({
    required String weekNumber,
    required String dateRange,
    required String status,
    required String statusLabel,
    required IconData statusIcon,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
      padding: const EdgeInsets.all(AppConstants.itemPadding),
      decoration: AppDecorations.itemCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week $weekNumber',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: AppDecorations.statusContainer.copyWith(
                  color: statusColor.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AppTypography.status.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateRange,
            style: AppTypography.subtitle,
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyLogCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.emptyCard,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.error.withOpacity(0.6),
            size: AppConstants.iconSizeLarge,
          ),
          const SizedBox(width: AppConstants.itemSpacing),
          Text(
            'No weekly logs available yet.',
            style: AppTypography.body.copyWith(
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildNoInternshipSection({required VoidCallback onRequestPressed}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.iconPadding),
                decoration: AppDecorations.iconContainer,
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Text(
                'Internship Status',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          Container(
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            decoration: AppDecorations.emptyCard,
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.error.withOpacity(0.6),
                  size: 48,
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                Text(
                  'No ongoing internship',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have an ongoing internship. Send a request to start one.',
                  style: AppTypography.body.copyWith(color: AppColors.primary.shade900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                ElevatedButton(
                  onPressed: onRequestPressed,
                  style: AppWidgetStyles.elevatedButton,
                  child: Text(
                    'Send Internship Request',
                    style: AppTypography.button,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPendingRequestsSection({
    required List<dynamic> pendingRequests,
    required String Function(String) getStatusLabel,
    required IconData Function(String) getStatusIcon,
    required Color Function(String) getStatusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      margin: const EdgeInsets.only(top: AppConstants.itemSpacing),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.iconPadding),
                decoration: AppDecorations.iconContainer,
                child: Icon(
                  Icons.pending_actions,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Text(
                'Pending Requests',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          if (pendingRequests.isNotEmpty)
            ...pendingRequests.map((request) {
              final status = request['status'] ?? 'pending_approval';
              final statusLabel = getStatusLabel(status);
              final statusColor = status == 'pending_approval' ? AppColors.pending : getStatusColor(status);
              final statusIcon = status == 'pending_approval' ? Icons.access_time : getStatusIcon(status);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
                padding: const EdgeInsets.all(AppConstants.itemPadding),
                decoration: AppDecorations.itemCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company: ${request['company']?.toString() ?? 'Not available'}',
                      style: AppTypography.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: AppTypography.subtitle,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: AppDecorations.statusContainer.copyWith(
                            color: statusColor.withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: AppTypography.status.copyWith(color: statusColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Container(
              padding: const EdgeInsets.all(AppConstants.cardPadding),
              decoration: AppDecorations.emptyCard,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary.withOpacity(0.6),
                    size: AppConstants.iconSizeLarge,
                  ),
                  const SizedBox(width: AppConstants.itemSpacing),
                  Text(
                    'No pending requests.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary.withOpacity(0.7),
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