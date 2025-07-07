import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import '../../widgets/company_dashboard_widget.dart';
import '../../services/company_dashboard_service.dart';
import '../../widgets/internship_request_item.dart';

class PendingRequestsScreen extends StatelessWidget {
  final List<dynamic> requests;
  final VoidCallback onRequestProcessed;

  const PendingRequestsScreen({
    super.key,
    required this.requests,
    required this.onRequestProcessed,
  });

  @override
  Widget build(BuildContext context) {
    final service = CompanyDashboardService();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pending Internship Requests',
          style: AppTypography.headline.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
        child: requests.isEmpty
            ? Center(child: CompanyDashboardWidgets.buildEmptyCard('No pending requests'))
            : ListView.builder(
          padding: const EdgeInsets.all(AppConstants.itemPadding),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return InternshipRequestItem(
              request: requests[index],
              iconColorIndex: index,
              onRequestProcessed: onRequestProcessed,
              getSupervisors: service.getSupervisors,
              approveRequest: service.approveRequest,
              rejectRequest: service.rejectRequest,
            );
          },
        ),
      ),
    );
  }
}