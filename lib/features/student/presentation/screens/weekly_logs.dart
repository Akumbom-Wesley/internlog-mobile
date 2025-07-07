import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';
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
              'Error fetching logs: $e',
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
    if (_logbookId == null) return;
    try {
      await DioClient().createWeeklyLog(_logbookId!);
      await _fetchWeeklyLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Weekly log created successfully',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.success.withOpacity(0.1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create weekly log: $e',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error.withOpacity(0.1),
          ),
        );
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
            style: AppTypography.headerTitle,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: const [SizedBox(width: AppConstants.iconSizeMedium)],
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.2),
        ),
        floatingActionButton: _logbookId != null
            ? FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: _createWeeklyLog,
        )
            : null,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _weeklyLogs.isEmpty
            ? Center(
          child: Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            margin: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: AppConstants.iconSizeLarge,
                  color: AppColors.primary.shade500,
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  'No weekly logs available yet.\nTap the + button to create one.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
            : ListView.builder(
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
        bottomNavigationBar: BottomNavBar(
          role: widget.role ?? 'student',
          currentIndex: 1,
        ),
      ),
    );
  }
}