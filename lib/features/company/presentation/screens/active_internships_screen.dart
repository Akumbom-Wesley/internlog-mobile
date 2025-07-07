import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import '../../widgets/company_dashboard_widget.dart';
import '../../widgets/internship_item.dart';

class ActiveInternshipsScreen extends StatelessWidget {
  final List<dynamic> internships;

  const ActiveInternshipsScreen({super.key, required this.internships});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Internships',
          style: AppTypography.headline.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
        child: internships.isEmpty
            ? Center(child: CompanyDashboardWidgets.buildEmptyCard('No active internships'))
            : ListView.builder(
          padding: const EdgeInsets.all(AppConstants.itemPadding),
          itemCount: internships.length,
          itemBuilder: (context, index) {
            return InternshipItem(
              internship: internships[index],
              iconColorIndex: index,
              formatDate: (date) => date?.toString().split('T')[0] ?? 'Not available',
            );
          },
        ),
      ),
    );
  }
}