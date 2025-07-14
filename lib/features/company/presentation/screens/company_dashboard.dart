import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../services/company_dashboard_service.dart';
import '../../widgets/company_dashboard_widget.dart';
import 'active_internships_screen.dart';
import 'pending_requests_screen.dart';

class CompanyDashboard extends StatefulWidget {
  final String role;
  const CompanyDashboard({super.key, required this.role});

  @override
  _CompanyDashboardState createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  final CompanyDashboardService _service = CompanyDashboardService();
  List<dynamic>? _activeInternships;
  List<dynamic>? _pendingRequests;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchCompanyData();
      setState(() {
        _activeInternships = result['activeInternships'];
        _pendingRequests = result['pendingRequests'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error fetching data: $e',
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
              CompanyDashboardWidgets.buildCompanyHeader(),
              const SizedBox(height: AppConstants.sectionSpacing),
              CompanyDashboardWidgets.buildActiveInternshipsSection(
                activeInternships: _activeInternships ?? [],
                onViewAllPressed: () {
                  context.go(
                    '/company/internships',
                    extra: {'internships': _activeInternships ?? []},
                  );
                },
                formatDate: _service.formatDate,
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              CompanyDashboardWidgets.buildPendingRequestsSection(
                pendingRequests: _pendingRequests ?? [],
                onViewAllPressed: () {
                  context.go(
                    '/company/requests',
                    extra: {
                      'requests': _pendingRequests ?? [],
                      'onRequestProcessed': _fetchData,
                    },
                  );
                },
                onRequestProcessed: _fetchData,
                getSupervisors: _service.getSupervisors,
                approveRequest: _service.approveRequest,
                rejectRequest: _service.rejectRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}