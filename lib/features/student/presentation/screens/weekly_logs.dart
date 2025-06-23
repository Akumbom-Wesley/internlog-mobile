// lib/features/user/presentation/screens/weekly_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';

class WeeklyLogsScreen extends StatefulWidget {
  const WeeklyLogsScreen({super.key});

  @override
  State<WeeklyLogsScreen> createState() => _WeeklyLogsScreenState();
}

class _WeeklyLogsScreenState extends State<WeeklyLogsScreen> {
  bool _isLoading = true;
  List<dynamic> _weeklyLogs = [];
  int? _logbookId;
  int _iconIndex = 0;
  DateTime? _internshipStartDate;

  final List<Color> _iconColors = [
    const Color(0xFF1A237E),
    const Color(0xFF283593),
    const Color(0xFF3949AB),
    const Color(0xFF5C6BC0),
  ];

  @override
  void initState() {
    super.initState();
    _fetchWeeklyLogs();
  }

  Future<void> _fetchWeeklyLogs() async {
    setState(() => _isLoading = true);
    final dioClient = DioClient();
    try {
      final internship = await dioClient.getOngoingInternship();
      final logbook = await dioClient.getOngoingLogbook(internship['id']);

      final startDateStr = internship['start_date'];
      _internshipStartDate = DateTime.tryParse(startDateStr);

      setState(() {
        _logbookId = logbook['id'];
        _weeklyLogs = logbook['weekly_logs'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching logs: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateRange(DateTime? startDate) {
    if (startDate == null) return 'Date range not available';
    final endDate = startDate.add(const Duration(days: 4));
    return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}';
  }

  DateTime? _parseStartDate(dynamic log) {
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
        if (_internshipStartDate != null && weekNo is int) {
          return _internshipStartDate!.add(Duration(days: 7 * (weekNo - 1)));
        }
      }
    } catch (e) {
      debugPrint('Error parsing start date: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return WillPopScope(
      onWillPop: () async {
        context.go('/user/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Weekly Logs',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryColor,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/user/dashboard'),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        floatingActionButton: _logbookId != null
            ? FloatingActionButton(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () async {
            try {
              await DioClient().createWeeklyLog(_logbookId!);
              _fetchWeeklyLogs();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to create weekly log: $e')),
                );
              }
            }
          },
        )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _weeklyLogs.isEmpty
            ? Center(
          child: Text(
            'No weekly logs available yet.\nTap the + button to create one.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        )
            : ListView.builder(
          itemCount: _weeklyLogs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final log = _weeklyLogs[index];
            final weekNo = (log['week_no']?.toString() ?? 'Unknown').toString();
            final status = (log['status'] ?? 'pending_approval').toString();
            final range = _formatDateRange(_parseStartDate(log));

            IconData statusIcon;
            Color statusColor;
            switch (status) {
              case 'approved':
                statusIcon = Icons.check_circle;
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusIcon = Icons.cancel;
                statusColor = Colors.red;
                break;
              default:
                statusIcon = Icons.hourglass_empty;
                statusColor = Colors.orange;
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(Icons.calendar_today, color: _iconColors[index % _iconColors.length]),
              title: Text(
                'Week $weekNo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        status.replaceAll('_', ' ').toTitleCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                final weekId = log['id']?.toString() ?? '0';
                context.push('/user/logbook/week/$weekId');
              },
            );
          },
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
  }
}