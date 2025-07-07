import 'package:flutter/material.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';

class SupervisorDashboardService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> fetchSupervisorData() async {
    final userData = await _dioClient.getCurrentUser();
    final supervisorName = userData['full_name']?.toString() ?? 'Unknown Supervisor';
    final supervisorEmail = userData['email']?.toString() ?? 'Not available';
    List<dynamic> assignedStudents = [];
    List<dynamic> recentActivities = [];

    try {
      final studentsResponse = await _dioClient.getAssignedStudents();
      assignedStudents = (studentsResponse is List)
          ? studentsResponse
          .where((student) => student != null)
          .map((student) => {
        'full_name': student['internship_requests']?[0]['student']?.split(' - ')[0] ?? 'Unknown Student',
        'matricule_num': student['matricule_num']?.toString() ?? 'Unknown Matricule',
        'company': student['internship_requests']?[0]['company']?.toString() ?? 'Unknown Company',
        'status': student['internship_requests']?[0]['status']?.toString() ?? 'active',
      })
          .toList()
          : [];
    } catch (e) {
      if (!e.toString().contains('No assigned students found')) {
        throw Exception('Error loading assigned students: $e');
      }
    }

    try {
      final activitiesResponse = await _dioClient.getRecentActivities();
      recentActivities = (activitiesResponse is List)
          ? activitiesResponse
          .where((activity) => activity != null)
          .map((activity) => {
        'student_name': activity['student']?['name']?.toString() ?? 'Unknown Student',
        'description': activity['description']?.toString() ?? 'Submitted logbook entry',
        'time_ago': _calculateTimeAgo(activity['entry_date']),
        'logbook_id': activity['entry_id'],
        'activity_type': activity['activity_type']?.toString() ?? 'logbook_entry',
      })
          .toList()
          : [];
    } catch (e) {
      if (!e.toString().contains('No recent activities found')) {
        throw Exception('Error loading recent activities: $e');
      }
    }

    return {
      'supervisorName': supervisorName,
      'supervisorEmail': supervisorEmail,
      'assignedStudents': assignedStudents,
      'recentActivities': recentActivities,
    };
  }

  Future<Map<String, dynamic>> getLogbook(int logbookId) async {
    return await _dioClient.getLogbook(logbookId);
  }

  String _calculateTimeAgo(String? entryDate) {
    if (entryDate == null) return 'Unknown time';
    try {
      final now = DateTime.now();
      final entry = DateTime.parse(entryDate);
      final difference = now.difference(entry);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      return '${difference.inMinutes}m ago';
    } catch (e) {
      return 'Unknown time';
    }
  }

  Color getStatusColor(String status) {
    const statusColors = {
      'active': AppColors.approved,
      'pending': AppColors.pending,
    };
    return statusColors[status] ?? AppColors.primary;
  }

  IconData getActivityIcon(String activityType) {
    const activityIcons = {
      'logbook_entry': Icons.book,
      'evaluation': Icons.grade,
    };
    return activityIcons[activityType] ?? Icons.work;
  }

  Color getActivityColor(String activityType) {
    const activityColors = {
      'logbook_entry': AppColors.info,
      'evaluation': AppColors.success,
    };
    return activityColors[activityType] ?? AppColors.activity;
  }
}