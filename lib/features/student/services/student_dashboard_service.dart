import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';

class StudentDashboardService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> fetchStudentData() async {
    final userData = await _dioClient.getCurrentUser();
    final studentName = userData['full_name']?.toString() ?? 'Unknown';
    final matriculeNum = userData['matricule_num']?.toString() ?? 'Not available';
    Map<String, dynamic>? currentInternship;
    Map<String, dynamic>? ongoingLogbook;
    List<dynamic>? pendingRequests;

    try {
      final internship = await _dioClient.getOngoingInternship();
      if (internship != null) {
        currentInternship = internship;
        int internshipId = 0;
        if (internship['id'] is int) {
          internshipId = internship['id'];
        } else if (internship['id'] is String) {
          internshipId = int.tryParse(internship['id']) ?? 0;
        }
        if (internshipId > 0) {
          final logbook = await _dioClient.getOngoingLogbook(internshipId);
          if (logbook != null && logbook is Map) {
            ongoingLogbook = Map<String, dynamic>.from(logbook);
          }
        }
      }
    } catch (e) {
      if (!e.toString().contains('No ongoing internship found')) {
        throw Exception('Error loading internship: $e');
      }
    }

    try {
      final requests = await _dioClient.get('api/students/requests/list?status=pending');
      pendingRequests = requests is List ? requests : [];
    } catch (e) {
      if (!e.toString().contains('No pending requests found')) {
        throw Exception('Error loading pending requests: $e');
      }
      pendingRequests = [];
    }

    return {
      'studentName': studentName,
      'matriculeNum': matriculeNum,
      'currentInternship': currentInternship,
      'ongoingLogbook': ongoingLogbook,
      'pendingRequests': pendingRequests,
    };
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final day = dateTime.day;
    final suffix = _getOrdinalSuffix(day);
    final formatter = DateFormat('d\'$suffix\' MMMM');
    return formatter.format(dateTime);
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String getInternshipDatesFormatted(Map<String, dynamic> internship) {
    final startDate = internship['start_date'];
    final endDate = internship['end_date'];
    if (startDate == null || endDate == null) return 'Not available';
    try {
      return '${formatDate(startDate)} - ${formatDate(endDate)}';
    } catch (e) {
      return 'Not available';
    }
  }

  String getWeekDateRange(Map<String, dynamic> log) {
    if (log['logbook_entries'] != null && log['logbook_entries'].isNotEmpty) {
      final firstEntry = log['logbook_entries'][0];
      final createdAt = firstEntry['created_at'] as String;
      final startDate = DateTime.tryParse(createdAt.split('T')[0]);
      if (startDate != null) {
        final endDate = startDate.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}';
      }
    }
    return 'Date range not available';
  }

  String getStatusLabel(String status) {
    const statusMap = {
      'approved': 'Approved',
      'rejected': 'Rejected',
      'pending_approval': 'Pending Approval',
    };
    return statusMap[status] ?? status;
  }

  IconData getStatusIcon(String status) {
    const statusIcons = {
      'approved': Icons.check_circle,
      'rejected': Icons.cancel,
      'pending_approval': Icons.hourglass_empty,
    };
    return statusIcons[status] ?? Icons.help;
  }

  Color getStatusColor(String status) {
    const statusColors = {
      'approved': AppColors.approved,
      'rejected': AppColors.error,
      'pending_approval': AppColors.pending,
    };
    return statusColors[status] ?? AppColors.primary;
  }
}