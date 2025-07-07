import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'company_dashboard_widget.dart';

class InternshipItem extends StatelessWidget {
  final dynamic internship;
  final int iconColorIndex;
  final String Function(String?) formatDate;

  const InternshipItem({
    super.key,
    required this.internship,
    required this.iconColorIndex,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.iconColors[iconColorIndex % AppColors.iconColors.length];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
      padding: const EdgeInsets.all(AppConstants.itemPadding),
      decoration: AppDecorations.itemCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            internship['student']?['full_name']?.toString() ?? 'Unknown Student',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          CompanyDashboardWidgets.buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Duration',
            value: '${formatDate(internship['start_date']?.toString())} - ${formatDate(internship['end_date']?.toString())}',
            iconColor: iconColor,
          ),
          CompanyDashboardWidgets.buildDetailRow(
            icon: Icons.person_outline,
            label: 'Supervisor',
            value: internship['supervisor']?['user_name']?.toString() ?? 'Not assigned',
            iconColor: iconColor,
          ),
          CompanyDashboardWidgets.buildDetailRow(
            icon: Icons.info,
            label: 'Status',
            value: internship['status']?.toString().toUpperCase() ?? 'Not available',
            iconColor: iconColor,
          ),
        ],
      ),
    );
  }
}