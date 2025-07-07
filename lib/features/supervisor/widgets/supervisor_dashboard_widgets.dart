import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';

class SupervisorDashboardWidgets {
  static Widget buildSupervisorHeader({
    required String? supervisorName,
    required String? supervisorEmail,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.headerCard,
      child: Row(
        children: [
          AppWidgetStyles.headerAvatar(text: supervisorName ?? ''),
          const SizedBox(width: AppConstants.sectionSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supervisorName ?? 'Loading...',
                  style: AppTypography.headerTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Supervisor • ${supervisorEmail ?? 'Loading...'}',
                  style: AppTypography.headerSubtitle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.iconPadding),
            decoration: AppDecorations.iconContainer,
            child: Icon(
              Icons.supervisor_account,
              color: Colors.white,
              size: AppConstants.iconSizeLarge,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildStatsOverview({
    required int totalStudents,
    required int recentActivitiesCount,
  }) {
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
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Text(
                'Overview',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Students',
                  totalStudents.toString(),
                  Icons.people,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Expanded(
                child: _buildStatCard(
                  'Recent Activities',
                  recentActivitiesCount.toString(),
                  Icons.timeline,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.itemPadding),
      decoration: AppDecorations.itemCard.copyWith(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.iconPadding),
            decoration: AppDecorations.iconContainer.copyWith(
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconSizeMedium),
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.subtitle.copyWith(
              color: color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildAssignedStudentsSection({
    required List<dynamic> assignedStudents,
    required Color Function(String) getStatusColor,
  }) {
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
                  Icons.people_outline,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Text(
                'Assigned Students',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          if (assignedStudents.isEmpty)
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
                    'No assigned students found.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ...assignedStudents.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              final fullName = student['full_name']?.toString() ?? 'Unknown Student';
              final matriculeNum = student['matricule_num']?.toString() ?? 'Unknown Matricule';
              final company = student['company']?.toString() ?? 'Unknown Company';
              final status = student['status']?.toString() ?? 'active';

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
                padding: const EdgeInsets.all(AppConstants.itemPadding),
                decoration: AppDecorations.itemCard,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.iconColors[index % AppColors.iconColors.length].withOpacity(0.1),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                        style: AppTypography.body.copyWith(
                          color: AppColors.iconColors[index % AppColors.iconColors.length],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.sectionSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $matriculeNum',
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: AppDecorations.statusContainer.copyWith(
                        color: getStatusColor(status).withOpacity(0.1),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTypography.status.copyWith(
                          color: getStatusColor(status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: AppConstants.iconSizeSmall,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  static Widget buildRecentActivitiesSection({
    required List<dynamic> recentActivities,
    required IconData Function(String) getActivityIcon,
    required Color Function(String) getActivityColor,
    required Function(int) onActivityTap,
  }) {
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
                  Icons.timeline,
                  color: AppColors.primary,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              Text(
                'Recent Activities',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          if (recentActivities.isEmpty)
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
                    'No recent activities found.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentActivities.map((activity) {
              final studentName = activity['student_name']?.toString() ?? 'Unknown Student';
              final description = activity['description']?.toString() ?? 'Submitted logbook entry';
              final timeAgo = activity['time_ago']?.toString() ?? 'Unknown time';
              final logbookId = activity['logbook_id'];
              final activityType = activity['activity_type']?.toString() ?? 'logbook_entry';

              return Container(
                margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
                padding: const EdgeInsets.all(AppConstants.itemPadding),
                decoration: AppDecorations.itemCard,
                child: InkWell(
                  onTap: logbookId != null ? () => onActivityTap(logbookId) : null,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.iconPadding),
                        decoration: AppDecorations.iconContainer.copyWith(
                          color: getActivityColor(activityType).withOpacity(0.1),
                        ),
                        child: Icon(
                          getActivityIcon(activityType),
                          color: getActivityColor(activityType),
                          size: AppConstants.iconSizeMedium,
                        ),
                      ),
                      const SizedBox(width: AppConstants.sectionSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: AppTypography.body,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: AppTypography.subtitle,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeAgo,
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: AppConstants.iconSizeSmall,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}