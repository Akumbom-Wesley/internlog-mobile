import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import '../../../auth/presentation/widgets/bottom_navigation_bar.dart';

class WeeklyLogsScreen extends StatefulWidget {
  final String? role;
  const WeeklyLogsScreen({super.key, this.role});

  @override
  State<WeeklyLogsScreen> createState() => _WeeklyLogsScreenState();
}

class _WeeklyLogsScreenState extends State<WeeklyLogsScreen> {
  bool _isLoading = true;
  List<dynamic> _weeklyLogs = [];
  int? _logbookId;
  DateTime? _internshipStartDate;

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

  Widget _buildStatusWidget(String status) {
    switch (status) {
      case 'approved':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Approved',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      case 'rejected':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                'Rejected',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: Colors.amber[700], size: 16),
              const SizedBox(width: 4),
              Text(
                'Pending Review',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        );
    }
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text(
              'Weekly Logs',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          leading: BackButton(onPressed: () => context.pop()),
          actions: const [SizedBox(width: 48)],
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No weekly logs available yet.\nTap the + button to create one.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final weekId = log['id']?.toString() ?? '0';
                    context.push('/user/logbook/week/$weekId');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Week number indicator
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              weekNo,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Week details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Week $weekNo',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                range,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (log['logbook_entries'] != null &&
                                  log['logbook_entries'].isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.list_alt,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${log['logbook_entries'].length} entries',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Status and arrow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStatusWidget(status),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavBar(
          role: widget.role ?? 'student',
          currentIndex: 1,
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