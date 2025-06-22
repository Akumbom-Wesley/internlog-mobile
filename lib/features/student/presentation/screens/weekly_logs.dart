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
    const Color(0xFF1A237E), // Dark blue
    const Color(0xFF283593), // Medium blue
    const Color(0xFF3949AB), // Light blue
    const Color(0xFF5C6BC0), // Very light blue
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

        // Fallback: infer from internship start date + week offset
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


  Color _getNextIconColor() {
    final color = _iconColors[_iconIndex % _iconColors.length];
    _iconIndex = (_iconIndex + 1) % _iconColors.length;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    _iconIndex = 0; // Reset for each build

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
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _weeklyLogs.isEmpty
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
                  itemBuilder: (context, index) {
                    final log = _weeklyLogs[index];

                    // Safely extract values with null checks
                    final weekNo = (log['week_no']?.toString() ?? 'Unknown').toString();
                    final status = (log['status'] ?? 'pending_approval').toString();
                    final range = _formatDateRange(_parseStartDate(log));

                    return _buildLogCard(
                      context: context,
                      weekNo: weekNo,
                      range: range,
                      status: status,
                      onTap: () => context.go('/user/logbook/week/$weekNo'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required BuildContext context,
    required String weekNo,
    required String range,
    required String status,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final iconColor = _getNextIconColor();

    String statusLabel;
    IconData statusIcon;
    Color statusColor;

    switch (status) {
      case 'approved':
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        break;
      case 'pending_approval':
      default:
        statusLabel = 'Pending Approval';
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Week $weekNo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}