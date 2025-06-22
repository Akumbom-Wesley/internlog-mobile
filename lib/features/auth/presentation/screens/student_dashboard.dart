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
      print('=== Starting _fetchStudentData ===');

      // 1. Get user data
      print('Step 1: Fetching user data...');
      final userData = await dioClient.getCurrentUser();
      print('User data received: $userData');
      print('User data type: ${userData.runtimeType}');

      // 2. Get internship data
      print('Step 2: Fetching internship data...');
      final internship = await dioClient.getOngoingInternship();
      print('Internship data received: $internship');
      print('Internship data type: ${internship.runtimeType}');

      if (internship != null) {
        print('Step 3: Processing internship data...');

        // 3. Safely access student data
        Map<String, dynamic> studentData = {};
        print('Checking internship[\'student\']...');
        print('internship[\'student\'] = ${internship['student']}');
        print('internship[\'student\'] type = ${internship['student'].runtimeType}');

        if (internship['student'] is Map) {
          studentData = Map<String, dynamic>.from(internship['student']);
          print('Student data extracted: $studentData');
        } else {
          print('Warning: internship[\'student\'] is not a Map!');
        }

        // 4. Safely parse internship ID
        print('Step 4: Processing internship ID...');
        print('internship[\'id\'] = ${internship['id']}');
        print('internship[\'id\'] type = ${internship['id'].runtimeType}');

        int internshipId = 0;
        if (internship['id'] != null) {
          if (internship['id'] is int) {
            internshipId = internship['id'];
          } else if (internship['id'] is String) {
            internshipId = int.tryParse(internship['id']) ?? 0;
          }
        }
        print('Parsed internship ID: $internshipId');

        // 5. Safely extract names and data
        print('Step 5: Extracting display data...');
        String studentName = '';
        String matriculeNum = '';

        try {
          studentName = userData['full_name']?.toString() ?? 'Unknown';
          print('Student name extracted: $studentName');
        } catch (e) {
          print('Error extracting student name: $e');
          studentName = 'Unknown';
        }

        try {
          matriculeNum = studentData['matricule_num']?.toString() ?? 'Not available';
          print('Matricule number extracted: $matriculeNum');
        } catch (e) {
          print('Error extracting matricule number: $e');
          matriculeNum = 'Not available';
        }

        setState(() {
          _currentInternship = internship;
          _studentName = studentName;
          _matriculeNum = matriculeNum;
        });
        print('State updated successfully');

        // 6. Only fetch logbook if we have a valid ID
        if (internshipId > 0) {
          print('Step 6: Fetching logbook for internship ID: $internshipId');
          try {
            final logbook = await dioClient.getOngoingLogbook(internshipId);
            print('Logbook data received: $logbook');

            if (logbook != null && logbook is Map) {
              setState(() {
                _ongoingLogbook = Map<String, dynamic>.from(logbook);
              });
              print('Logbook state updated successfully');
            }
          } catch (logbookError) {
            print('Error fetching logbook: $logbookError');
            // Don't throw here, just log the error
          }
        } else {
          print('Invalid internship ID: ${internship['id']}');
        }
      } else {
        print('No internship data received');
      }

      print('=== _fetchStudentData completed successfully ===');
    } catch (e, stackTrace) {
      print('=== Error in _fetchStudentData ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');

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
    final formatter = DateFormat('d\'$suffix\' MMMM, yyyy');
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    value.isNotEmpty ? value : 'Not available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    iconIndex = 0; // Reset icon index for each build

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Information
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    _studentName?.isNotEmpty ?? false ? _studentName![0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studentName ?? 'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Student ID: ${_matriculeNum ?? 'Loading...'}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Internship Details Section
            Text(
              'Internship Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.business,
              'Company',
              _currentInternship?['company']?.toString() ?? 'Tech Solutions Inc.',
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Dates',
              _currentInternship != null
                  ? '${_formatDate(_currentInternship!['start_date'])} - ${_formatDate(_currentInternship!['end_date'])}'
                  : 'Not available',
            ),
            _buildDetailRow(
              Icons.person,
              'Supervisor',
              _currentInternship?['supervisor']?['user_name']?.toString() ?? 'Not assigned',
            ),
            const SizedBox(height: 24),
            // Logbook Section
            Text(
              'Logbook',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.book,
              'View Logbook',
              'Week 1: June 3 - June 9', // Replace with dynamic week if available
              onTap: () {
                if (_currentInternship?['id'] != null && _ongoingLogbook?['id'] != null) {
                  // Navigate to logbook detail screen
                  // Example: context.go('/logbook/${_ongoingLogbook!['id']}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}