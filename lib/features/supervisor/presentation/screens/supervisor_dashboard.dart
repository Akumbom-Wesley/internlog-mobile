import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';
import '../../services/supervisor_dashboard_service.dart';
import '../../widgets/supervisor_dashboard_widgets.dart';

class SupervisorDashboard extends StatefulWidget {
  final String role;
  const SupervisorDashboard({super.key, required this.role});

  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final SupervisorDashboardService _service = SupervisorDashboardService();
  String? _supervisorName;
  String? _supervisorEmail;
  List<dynamic>? _assignedStudents;
  List<dynamic>? _recentActivities;
  bool _isLoading = true;
  int _currentIndex = 0; // Added to track the current tab

  @override
  void initState() {
    super.initState();
    _fetchSupervisorData();
  }

  Future<void> _fetchSupervisorData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchSupervisorData();
      setState(() {
        _supervisorName = result['supervisorName'];
        _supervisorEmail = result['supervisorEmail'];
        _assignedStudents = result['assignedStudents'];
        _recentActivities = result['recentActivities'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load supervisor data: $e',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error.withOpacity(0.1),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLogbookDetail(int logbookId) async {
    try {
      final logbookData = await _service.getLogbook(logbookId);
      if (context.mounted) {
        context.go('/supervisor/logbook/$logbookId', extra: widget.role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading logbook: $e',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error.withOpacity(0.1),
          ),
        );
      }
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/user/dashboard', extra: widget.role);
        break;
      case 1:
        context.go('/user/students', extra: widget.role);
        break;
      case 2:
        context.go('/user/profile', extra: widget.role);
        break;
    }
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
              SupervisorDashboardWidgets.buildSupervisorHeader(
                supervisorName: _supervisorName,
                supervisorEmail: _supervisorEmail,
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              SupervisorDashboardWidgets.buildStatsOverview(
                totalStudents: _assignedStudents?.length ?? 0,
                recentActivitiesCount: _recentActivities?.length ?? 0,
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              SupervisorDashboardWidgets.buildAssignedStudentsSection(
                assignedStudents: _assignedStudents ?? [],
                getStatusColor: _service.getStatusColor,
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              SupervisorDashboardWidgets.buildRecentActivitiesSection(
                recentActivities: _recentActivities ?? [],
                getActivityIcon: _service.getActivityIcon,
                getActivityColor: _service.getActivityColor,
                onActivityTap: _navigateToLogbookDetail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}