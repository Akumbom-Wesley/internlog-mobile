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
  List<dynamic>? _pendingRequests;
  bool _isLoading = true;
  int iconIndex = 0;

  final List<Color> iconColors = [
    Color(0xFF1A237E),
    Color(0xFF283593),
    Color(0xFF3949AB),
    Color(0xFF5C6BC0),
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
      final userData = await dioClient.getCurrentUser();
      setState(() {
        _studentName = userData['full_name']?.toString() ?? 'Unknown';
        _matriculeNum = userData['matricule_num']?.toString() ?? 'Not available';
      });

      try {
        final internship = await dioClient.getOngoingInternship();
        if (internship != null) {
          setState(() {
            _currentInternship = internship;
          });
          int internshipId = 0;
          if (internship['id'] is int) {
            internshipId = internship['id'];
          } else if (internship['id'] is String) {
            internshipId = int.tryParse(internship['id']) ?? 0;
          }
          if (internshipId > 0) {
            final logbook = await dioClient.getOngoingLogbook(internshipId);
            if (logbook != null && logbook is Map) {
              setState(() {
                _ongoingLogbook = Map<String, dynamic>.from(logbook);
              });
            }
          }
        }
      } catch (e) {
        if (!e.toString().contains('No ongoing internship found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading internship: $e')),
          );
        }
      }

      // Fetch pending requests
      try {
        final requests = await dioClient.get('api/students/requests/list?status=pending');
        setState(() {
          _pendingRequests = requests is List ? requests : [];
        });
      } catch (e) {
        if (!e.toString().contains('No pending requests found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading pending requests: $e')),
          );
        }
        setState(() {
          _pendingRequests = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load student data: $e')),
      );
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
      final createdAt = firstEntry['created_at'] as String;
      final startDate = DateTime.tryParse(createdAt.split('T')[0]);
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
    final color = iconColors.isNotEmpty ? iconColors[iconIndex % iconColors.length] : Color(0xFF1A237E);
    if (iconColors.isNotEmpty) {
      iconIndex = (iconIndex + 1) % iconColors.length;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A237E).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF1A237E).withOpacity(0.1), width: 1),
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
                      color: Color(0xFF1A237E).withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : 'Not available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Color(0xFF1A237E),
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

  Widget _buildNoInternshipSection() {
    final primaryColor = Color(0xFF1A237E);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
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
                child: Icon(Icons.info_outline, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Internship Status',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFDC341D).withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFDC341D).withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFDC341D).withOpacity(0.6), size: 48),
                const SizedBox(height: 16),
                Text(
                  'No ongoing internship',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC341D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have an ongoing internship. Send a request to start one.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showInternshipRequestForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Send Internship Request',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    final primaryColor = Color(0xFF1A237E);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
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
                child: Icon(Icons.pending_actions, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Pending Requests',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_pendingRequests!.isNotEmpty)
            ..._pendingRequests!.map((request) {
              final status = request['status'] ?? 'pending_approval';
              final statusLabel = _getStatusLabel(status);
              final statusColor = status == 'pending_approval' ? Colors.yellow[700]! : _getStatusColor(status);
              final statusIcon = status == 'pending_approval' ? Icons.access_time : _getStatusIcon(status);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company: ${request['company']?.toString() ?? 'Not available'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryColor.withOpacity(0.7),
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList()
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor.withOpacity(0.6), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'No pending internship requests.',
                    style: GoogleFonts.poppins(
                      color: primaryColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showInternshipRequestForm() {
    showDialog(
      context: context,
      builder: (context) => InternshipRequestFormDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF1A237E);
    iconIndex = 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor.withOpacity(0.02), Colors.white],
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
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
            if (_currentInternship != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.05),
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
                          child: Icon(Icons.work_outline, color: primaryColor, size: 24),
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
                      _currentInternship!['company']?.toString() ?? 'Not available',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Duration',
                      _getInternshipDatesFormatted(),
                    ),
                    _buildDetailRow(
                      Icons.person,
                      'Supervisor',
                      _currentInternship!['supervisor']?['user_name']?.toString() ?? 'Not assigned',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.05),
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
                          child: Icon(Icons.trending_up, color: primaryColor, size: 24),
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
                            color: primaryColor.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
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
                                  color: primaryColor.withOpacity(0.7),
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
                          color: Color(0xFFDC341D).withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFDC341D).withOpacity(0.1), width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFDC341D).withOpacity(0.6), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'No weekly logs available yet.',
                              style: GoogleFonts.poppins(
                                color: Color(0xFFDC341D).withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              _buildNoInternshipSection(),
              if (_pendingRequests != null) _buildPendingRequestsSection(),
            ],
          ],
        ),
      ),
    );
  }
}

class InternshipRequestFormDialog extends StatefulWidget {
  @override
  _InternshipRequestFormDialogState createState() => _InternshipRequestFormDialogState();
}

class _InternshipRequestFormDialogState extends State<InternshipRequestFormDialog> {
  List<dynamic> _companies = [];
  List<dynamic> _academicYears = [];
  bool _isLoading = true;
  String? _selectedCompany;
  String? _selectedAcademicYear;
  DateTime? _startDate;
  DateTime? _endDate;
  String _jobDescription = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dioClient = DioClient();
      final companiesList = await dioClient.get('api/companies/list');
      final academicYearsList = await dioClient.get('api/academic-years/list');
      setState(() {
        _companies = List<dynamic>.from(companiesList);
        _academicYears = List<dynamic>.from(academicYearsList);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load form data: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedCompany == null ||
        _selectedAcademicYear == null ||
        _startDate == null ||
        _endDate == null ||
        _jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    try {
      final dioClient = DioClient();
      await dioClient.post('api/students/requests/create/', data: {
        'company': _selectedCompany,
        'academic_year': _selectedAcademicYear,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'job_description': _jobDescription,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Internship request sent successfully.')),
      );

      Navigator.of(context).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final state = context.findAncestorStateOfType<_StudentDashboardState>();
          if (state != null && state.mounted) {
            state._fetchStudentData();
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Internship Request', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Company'),
              items: _companies.map((company) {
                return DropdownMenuItem(
                  value: company['id'].toString(),
                  child: Text(company['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCompany = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Academic Year'),
              items: _academicYears.map((year) {
                return DropdownMenuItem(
                  value: year['id'].toString(),
                  child: Text(year['label']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAcademicYear = value),
            ),
            ListTile(
              title: Text('Start Date'),
              subtitle: Text(_startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : 'Select date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),
            ListTile(
              title: Text('End Date'),
              subtitle: Text(_endDate != null
                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                  : 'Select date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) setState(() => _endDate = date);
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Job Description'),
              maxLines: 3,
              onChanged: (value) => _jobDescription = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
        ElevatedButton(onPressed: _submitRequest, child: Text('Submit')),
      ],
    );
  }
}