import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/network/dio_client.dart';

class StudentsService {
  final DioClient _dioClient = DioClient();

  Future<List<dynamic>> fetchAssignedStudents() async {
    try {
      final result = await _dioClient.get('api/supervisors/assigned-students/');
      return result;
    } catch (e) {
      throw Exception('Failed to fetch assigned students: $e');
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
        return AppColors.rejected;
      default:
        return AppColors.info;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}