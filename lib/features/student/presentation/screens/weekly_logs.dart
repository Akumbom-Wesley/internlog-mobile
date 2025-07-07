import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';

import '../../services/weekly_logs_service.dart';
import '../../widgets/weekly_logs_widgets.dart';

class WeeklyLogsScreen extends StatefulWidget {
  final String? role;
  const WeeklyLogsScreen({super.key, this.role});

  @override
  State<WeeklyLogsScreen> createState() => _WeeklyLogsScreenState();
}

class _WeeklyLogsScreenState extends State<WeeklyLogsScreen> {
  final WeeklyLogsService _service = WeeklyLogsService();
  bool _isLoading = true;
  List<dynamic> _weeklyLogs = [];
  int? _logbookId;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyLogs();
  }

  Future<void> _fetchWeeklyLogs() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchWeeklyLogs();
      setState(() {
        _logbookId = result['logbookId'];
        _weeklyLogs = result['weeklyLogs'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error fetching logs: ${e.toString()}',
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

  Future<void> _createWeeklyLog() async {
    if (_logbookId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No active internship found',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error,
            
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.createWeeklyLog(_logbookId!);
      await _fetchWeeklyLogs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Week ${_weeklyLogs.length} created successfully',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create weekly log: ${e.toString()}',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/user/dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppDecorations.backgroundGradient.colors.last,
        appBar: AppBar(
          title: Text(
            'Weekly Logs',
            style: AppTypography.headerTitle.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/user/dashboard'),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: _createWeeklyLog,
          tooltip: 'Create new weekly log',
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _weeklyLogs.isEmpty
            ? WeeklyLogsWidgets.buildEmptyState()
            : RefreshIndicator(
          onRefresh: _fetchWeeklyLogs,
          color: AppColors.primary,
          child: ListView.builder(
            itemCount: _weeklyLogs.length,
            padding: const EdgeInsets.all(AppConstants.sectionSpacing),
            itemBuilder: (context, index) {
              final log = _weeklyLogs[index];
              return WeeklyLogsWidgets.buildLogCard(
                log: log,
                internshipStartDate: _service.internshipStartDate,
                onTap: () {
                  final weekId = log['id']?.toString() ?? '0';
                  context.push('/user/logbook/week/$weekId');
                },
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          role: widget.role ?? 'student',
          currentIndex: 1,
        ),
      ),
    );
  }
}