// lib/features/user/presentation/screens/student_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/network/dio_client.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String? _studentName;
  String? _matriculeNum;
  Map<String, dynamic>? _currentInternship;
  Map<String, dynamic>? _ongoingLogbook;
  bool _isLoading = true;
  int iconIndex = 0;

  final List<Color> iconColors = [
    Color(0xFF1A237E), // Dark blue
    Color(0xFF283593), // Medium blue
    Color(0xFF3949AB), // Light blue
    Color(0xFF5C6BC0), // Very light blue
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() => _isLoading = true);
    final dioClient = DioClient();
    try {
      // Get user data
      final userData = await dioClient.getCurrentUser();

      // Get internship data
      final internship = await dioClient.getOngoingInternship();

      if (internship != null) {
        // Safely access student data
        Map<String, dynamic> studentData = {};

        if (internship['student'] is Map) {
          studentData = Map<String, dynamic>.from(internship['student']);
        }

        // Safely parse internship ID
        int internshipId = 0;
        if (internship['id'] != null) {
          if (internship['id'] is int) {
            internshipId = internship['id'];
          } else if (internship['id'] is String) {
            internshipId = int.tryParse(internship['id']) ?? 0;
          }
        }

        // Safely extract names and data
        String studentName = '';
        String matriculeNum = '';

        try {
          studentName = userData['full_name']?.toString() ?? 'Unknown';
        } catch (e) {
          studentName = 'Unknown';
        }

        try {
          matriculeNum = studentData['matricule_num']?.toString() ?? 'Not available';
        } catch (e) {
          matriculeNum = 'Not available';
        }

        setState(() {
          _currentInternship = internship;
          _studentName = studentName;
          _matriculeNum = matriculeNum;
        });

        // Only fetch logbook if we have a valid ID
        if (internshipId > 0) {
          try {
            final logbook = await dioClient.getOngoingLogbook(internshipId);

            if (logbook != null && logbook is Map) {
              setState(() {
                _ongoingLogbook = Map<String, dynamic>.from(logbook);
              });
            }
          } catch (logbookError) {
            // Don't throw here, just log the error
          }
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load student data. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final day = dateTime.day;
    final suffix = _getOrdinalSuffix(day);
    final formatter = DateFormat('d\'$suffix\' MMMM');
    return formatter.format(dateTime);
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getInternshipDatesFormatted() {
    if (_currentInternship == null) return 'Not available';

    final startDate = _currentInternship!['start_date'];
    final endDate = _currentInternship!['end_date'];

    if (startDate == null || endDate == null) return 'Not available';

    try {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    } catch (e) {
      return 'Not available';
    }
  }

  String _getWeekDateRange(Map<String, dynamic> log) {
    if (log['logbook_entries'] != null && log['logbook_entries'].isNotEmpty) {
      final firstEntry = log['logbook_entries'][0];
      final createdAt = firstEntry['created_at'] as String; // Use the structured field
      final startDate = DateTime.tryParse(createdAt.split('T')[0]); // Extract date part

      if (startDate != null) {
        final endDate = startDate.add(Duration(days: 6));
        return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}';
      }
    }
    return 'Date range not available';
  }

  String _getStatusLabel(String status) {
    const statusMap = {
      'approved': 'Approved',
      'rejected': 'Rejected',
      'pending_approval': 'Pending Approval',
    };
    return statusMap[status] ?? status;
  }

  IconData _getStatusIcon(String status) {
    const statusIcons = {
      'approved': Icons.check_circle,
      'rejected': Icons.cancel,
      'pending_approval': Icons.hourglass_empty,
    };
    return statusIcons[status] ?? Icons.help;
  }

  Color _getStatusColor(String status) {
    const statusColors = {
      'approved': Colors.green,
      'rejected': Colors.red,
      'pending_approval': Colors.orange,
    };
    return statusColors[status] ?? Colors.grey;
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    // Safely get color with bounds checking
    final color = iconColors.isNotEmpty
        ? iconColors[iconIndex % iconColors.length]
        : Color(0xFF1A237E); // fallback color

    // Only increment if we have colors available
    if (iconColors.isNotEmpty) {
      iconIndex = (iconIndex + 1) % iconColors.length;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A237E).withOpacity(0.05), // Very light dark blue background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF1A237E).withOpacity(0.1), // Subtle dark blue border
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF1A237E).withOpacity(0.7), // Dark blue tint for labels
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : 'Not available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Color(0xFF1A237E), // Dark blue for values
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: value.contains('\n') ? 3 : 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF1A237E); // Use consistent dark blue
    iconIndex = 0; // Reset icon index for each build

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A237E).withOpacity(0.02), // Very subtle dark blue at top
            Colors.white,
          ],
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1A237E), // Dark blue background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1A237E).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        _studentName?.isNotEmpty ?? false ? _studentName![0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _studentName ?? 'Loading...',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Student ID: ${_matriculeNum ?? 'Loading...'}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Internship Details Section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF1A237E).withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1A237E).withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.work_outline,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Internship Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.business,
                      'Company',
                      _currentInternship?['company']?.toString() ?? 'Not available',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Duration',
                      _getInternshipDatesFormatted(),
                    ),
                    _buildDetailRow(
                      Icons.person,
                      'Supervisor',
                      _currentInternship?['supervisor']?['user_name']?.toString() ?? 'Not assigned',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Weekly Progress Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF1A237E).withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1A237E).withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Weekly Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_ongoingLogbook != null && _ongoingLogbook!['weekly_logs'] != null)
                      ..._ongoingLogbook!['weekly_logs'].map<Widget>((log) {
                        final status = log['status'] ?? 'pending_approval';
                        final statusLabel = _getStatusLabel(status);
                        final statusIcon = _getStatusIcon(status);
                        final statusColor = _getStatusColor(status);
                        final weekNumber = log['week_no'] ?? 'Unknown';

                        String dateRange = _getWeekDateRange(log);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A237E).withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF1A237E).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Week $weekNumber',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, color: statusColor, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusLabel,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateRange,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Color(0xFF1A237E).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A237E).withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF1A237E).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF1A237E).withOpacity(0.6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'No weekly logs available yet.',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF1A237E).withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}