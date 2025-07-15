import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/typography.dart';
import '../services/students_service.dart';

class StudentsWidgets {
  static Widget buildHeader(int studentCount, VoidCallback onRefresh) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.group,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned Students',
                  style: AppTypography.headerTitle.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$studentCount student${studentCount != 1 ? 's' : ''} assigned',
                  style: AppTypography.headerSubtitle.copyWith(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (studentCount > 0)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildStatusChip(String status, StudentsService service) {
    final color = service.getStatusColor(status);
    final icon = service.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildStudentAvatar(String matricule) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Center(
        child: Text(
          matricule.isNotEmpty ? matricule.substring(0, 2).toUpperCase() : 'ST',
          style: AppTypography.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildStudentCard(Map<String, dynamic> student, StudentsService service) {
    final dept = student['department']?['name'] ?? 'N/A';
    final school = student['department']?['school']?['name'] ?? '';
    final level = student['level'] ?? 'N/A';
    final matricule = student['matricule_num'] ?? 'N/A';

    final request = student['internship_requests']?[0];
    final company = request?['company'] ?? 'N/A';
    final status = request?['status'] ?? 'N/A';
    final startDate = request?['start_date'];
    final endDate = request?['end_date'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and basic info
            Row(
              children: [
                buildStudentAvatar(matricule),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        matricule,
                        style: AppTypography.headline.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level $level',
                        style: AppTypography.subtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                buildStatusChip(status, service),
              ],
            ),
            const SizedBox(height: 20),

            // Divider
            Container(
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),

            // Student details
            buildInfoRow(
              Icons.school_outlined,
              'Department',
              school.isNotEmpty ? '$dept, $school' : dept,
            ),
            buildInfoRow(
              Icons.business_outlined,
              'Company',
              company,
            ),
            buildInfoRow(
              Icons.date_range_outlined,
              'Duration',
              startDate != null && endDate != null
                  ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                  : 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Students Assigned',
            style: AppTypography.headline.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any students assigned to you yet.',
            style: AppTypography.caption.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}