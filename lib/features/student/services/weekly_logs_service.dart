import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/network/dio_client.dart';

class WeeklyLogsService {
  final DioClient _dioClient = DioClient();
  DateTime? internshipStartDate;

  Future<Map<String, dynamic>> fetchWeeklyLogs() async {
    final internship = await _dioClient.getOngoingInternship();
    final logbook = await _dioClient.getOngoingLogbook(internship['id']);
    final startDateStr = internship['start_date'];
    internshipStartDate = DateTime.tryParse(startDateStr);
    return {
      'logbookId': logbook['id'],
      'weeklyLogs': logbook['weekly_logs'] ?? [],
    };
  }

  String formatDateRange(DateTime? startDate) {
    if (startDate == null) return 'Date range not available';
    final endDate = startDate.add(const Duration(days: 4));
    return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}';
  }

  DateTime? parseStartDate(dynamic log) {
    try {
      if (log is Map) {
        final entries = log['logbook_entries'];
        if (entries is List && entries.isNotEmpty) {
          final firstEntry = entries[0];
          if (firstEntry is Map && firstEntry['created_at'] != null) {
            return DateTime.tryParse(firstEntry['created_at'].toString());
          }
        }
        final weekNo = log['week_no'];
        if (internshipStartDate != null && weekNo is int) {
          return internshipStartDate!.add(Duration(days: 7 * (weekNo - 1)));
        }
      }
    } catch (e) {
      debugPrint('Error parsing start date: $e');
    }
    return null;
  }
}