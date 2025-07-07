import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';


import '../services/weekly_logs_service.dart';

class WeeklyLogsWidgets {
  static Widget buildLogCard({
    required dynamic log,
    required DateTime? internshipStartDate,
    required VoidCallback onTap,
  }) {
    final weekNo = (log['week_no']?.toString() ?? 'Unknown').toString();
    final status = (log['status'] ?? 'pending_approval').toString();
    final range = WeeklyLogsService().formatDateRange(WeeklyLogsService().parseStartDate(log));

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        color: AppDecorations.card.color,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            decoration: AppDecorations.card.copyWith(
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: AppDecorations.iconContainer.copyWith(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      weekNo,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week $weekNo',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        range,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            size: AppConstants.iconSizeSmall,
                            color: AppColors.primary.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${log['logbook_entries'].length} entries',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusWidget(status),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary.shade500,
                      size: AppConstants.iconSizeMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildEmptyState() {
    return Center(
      child: Container(
        decoration: AppDecorations.card,
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: AppConstants.iconSizeLarge,
              color: AppColors.primary.shade500,
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            Text(
              'No weekly logs available yet.\nTap the + button to create one.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.primary.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusWidget(String status) {
    final statusConfig = {
      'approved': {
        'label': 'Approved',
        'icon': Icons.verified,
        'color': AppColors.approved,
      },
      'rejected': {
        'label': 'Rejected',
        'icon': Icons.cancel_outlined,
        'color': AppColors.error,
      },
      'pending_approval': {
        'label': 'Pending Review',
        'icon': Icons.schedule,
        'color': AppColors.pending,
      },
    }[status] ?? {
      'label': 'Pending Review',
      'icon': Icons.schedule,
      'color': AppColors.pending,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.iconPadding * 1.5,
        vertical: AppConstants.iconPadding,
      ),
      decoration: AppDecorations.statusContainer.copyWith(
        color: (statusConfig['color'] as Color).withOpacity(0.1),
        border: Border.all(
          color: (statusConfig['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig['icon'] as IconData,
            color: statusConfig['color'] as Color,
            size: AppConstants.iconSizeSmall,
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig['label'] as String,
            style: AppTypography.status.copyWith(
              color: statusConfig['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }
}