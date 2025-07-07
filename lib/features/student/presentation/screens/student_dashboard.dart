import 'package:flutter/material.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';

import '../../services/student_dashboard_service.dart';
import '../../widgets/internship_request_form_dialog.dart';
import '../../widgets/student_dashboard_widgets.dart';

class StudentDashboard extends StatefulWidget {
  final String role;
  const StudentDashboard({super.key, required  this.role});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentDashboardService _service = StudentDashboardService();
  String? _studentName;
  String? _matriculeNum;
  Map<String, dynamic>? _currentInternship;
  Map<String, dynamic>? _ongoingLogbook;
  List<dynamic>? _pendingRequests;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchStudentData();
      setState(() {
        _studentName = result['studentName'];
        _matriculeNum = result['matriculeNum'];
        _currentInternship = result['currentInternship'];
        _ongoingLogbook = result['ongoingLogbook'];
        _pendingRequests = result['pendingRequests'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load student data: $e',
            style: AppTypography.caption,
          ),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInternshipRequestForm() {
    showDialog(
      context: context,
      builder: (context) => InternshipRequestFormDialog(
        onSubmitSuccess: _fetchStudentData, // Pass callback to refresh data
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.itemPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                decoration: AppDecorations.headerCard,
                child: Row(
                  children: [
                    AppWidgetStyles.headerAvatar(
                      text: _studentName ?? '',
                      radius: 35,
                    ),
                    const SizedBox(width: AppConstants.sectionSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _studentName ?? 'Loading...',
                            style: AppTypography.headerTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Student ID: ${_matriculeNum ?? 'Loading...'}',
                            style: AppTypography.headerSubtitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.itemSpacing),
              if (_currentInternship != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.cardPadding),
                  decoration: AppDecorations.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.iconPadding),
                            decoration: AppDecorations.iconContainer,
                            child: Icon(
                              Icons.work_outline,
                              color: AppColors.primary,
                              size: AppConstants.iconSizeLarge,
                            ),
                          ),
                          const SizedBox(width: AppConstants.itemSpacing),
                          Text(
                            'Internship Details',
                            style: AppTypography.headline,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.itemSpacing),
                      StudentDashboardWidgets.buildDetailRow(
                        icon: Icons.business,
                        label: 'Company',
                        value: _currentInternship!['company']?.toString() ?? 'Not available',
                        iconColor: AppColors.iconColors[0],
                      ),
                      StudentDashboardWidgets.buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Duration',
                        value: _service.getInternshipDatesFormatted(_currentInternship!),
                        iconColor: AppColors.iconColors[1 % AppColors.iconColors.length],
                      ),
                      StudentDashboardWidgets.buildDetailRow(
                        icon: Icons.person,
                        label: 'Supervisor',
                        value: _currentInternship!['supervisor']?['user_name']?.toString() ?? 'Not assigned',
                        iconColor: AppColors.iconColors[2 % AppColors.iconColors.length],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Container(
                  padding: const EdgeInsets.all(AppConstants.cardPadding),
                  decoration: AppDecorations.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.iconPadding),
                            decoration: AppDecorations.iconContainer,
                            child: Icon(
                              Icons.trending_up,
                              color: AppColors.primary,
                              size: AppConstants.iconSizeLarge,
                            ),
                          ),
                          const SizedBox(width: AppConstants.itemSpacing),
                          Text(
                            'Weekly Progress',
                            style: AppTypography.headline,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.itemSpacing),
                      if (_ongoingLogbook != null && _ongoingLogbook!['weekly_logs'] != null)
                        ..._ongoingLogbook!['weekly_logs'].map<Widget>((log) {
                          final status = log['status'] ?? 'pending_approval';
                          return StudentDashboardWidgets.buildWeeklyLogCard(
                            weekNumber: log['week_no']?.toString() ?? 'Unknown',
                            dateRange: _service.getWeekDateRange(log),
                            status: status,
                            statusLabel: _service.getStatusLabel(status),
                            statusIcon: _service.getStatusIcon(status),
                            statusColor: _service.getStatusColor(status),
                          );
                        }).toList()
                      else
                        StudentDashboardWidgets.buildEmptyLogCard(),
                    ],
                  ),
                ),
              ] else ...[
                StudentDashboardWidgets.buildNoInternshipSection(
                  onRequestPressed: _showInternshipRequestForm,
                ),
                if (_pendingRequests != null)
                  StudentDashboardWidgets.buildPendingRequestsSection(
                    pendingRequests: _pendingRequests!,
                    getStatusLabel: _service.getStatusLabel,
                    getStatusIcon: _service.getStatusIcon,
                    getStatusColor: _service.getStatusColor,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}