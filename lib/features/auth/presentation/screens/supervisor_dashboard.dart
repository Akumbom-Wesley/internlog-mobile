// lib/features/user/presentation/screens/supervisor_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';

class SupervisorDashboard extends StatefulWidget {
  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  List<dynamic> _assignedStudents = [];
  List<dynamic> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSupervisorData();
  }

  Future<void> _fetchSupervisorData() async {
    setState(() => _isLoading = true);
    final dioClient = DioClient();
    try {
      final studentsResponse = await dioClient.getAssignedStudents();
      final activitiesResponse = await dioClient.getRecentActivities();

      setState(() {
        _assignedStudents = (studentsResponse is List)
            ? studentsResponse
            .where((student) => student != null)
            .map((student) => {
          'full_name': student['internship_requests'][0]['student'].split(' - ')[0],
          'matricule_num': student['matricule_num'],
        })
            .toList()
            : [];
        _recentActivities = (activitiesResponse is List)
            ? activitiesResponse
            .where((activity) => activity != null)
            .map((activity) => {
          'student_name': activity['student']['name'],
          'description': activity['description'],
          'time_ago': _calculateTimeAgo(activity['entry_date']),
          'logbook_id': activity['entry_id'],
        })
            .toList()
            : [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load supervisor data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _calculateTimeAgo(String entryDate) {
    final now = DateTime.now();
    final entry = DateTime.parse(entryDate);
    final difference = now.difference(entry);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    return '${difference.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assigned Students Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Assigned Students',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          _assignedStudents.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No assigned students found.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _assignedStudents.length,
            itemBuilder: (context, index) {
              final student = _assignedStudents[index];
              if (student == null) return const SizedBox.shrink();

              final fullName = student['full_name']?.toString() ?? 'Unknown Student';
              final matriculeNum = student['matricule_num']?.toString() ?? 'Unknown Matricule';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
                title: Text(
                  fullName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  matriculeNum,
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to student details screen if needed
                },
              );
            },
          ),
          // Recent Activity Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          _recentActivities.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No recent activities found.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _recentActivities.length,
            itemBuilder: (context, index) {
              final activity = _recentActivities[index];
              if (activity == null) return const SizedBox.shrink();

              final studentName = activity['student_name']?.toString() ?? 'Unknown Student';
              final description = activity['description']?.toString() ?? 'Submitted logbook entry';
              final timeAgo = activity['time_ago']?.toString() ?? 'Unknown time';
              final logbookId = activity['logbook_id'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
                title: Text(
                  studentName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  description,
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
                trailing: Text(
                  timeAgo,
                  style: GoogleFonts.poppins(color: Colors.black),
                ),
                onTap: () async {
                  if (logbookId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logbook ID not available')),
                    );
                    return;
                  }
                  try {
                    final dioClient = DioClient();
                    final logbookData = await dioClient.getLogbook(logbookId);
                    // Navigate to logbook detail screen with logbookData
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading logbook: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}