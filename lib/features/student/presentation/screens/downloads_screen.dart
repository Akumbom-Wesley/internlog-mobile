import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../auth/presentation/widgets/bottom_navigation_bar.dart';
import '../../cards/download_card.dart';
import '../../services/download_service.dart';
import '../../widgets/internship_selector_modal.dart';

class DownloadsScreen extends StatefulWidget {
  final String? role;
  const DownloadsScreen({super.key, this.role});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isDownloadingPdf = false;
  bool _isGeneratingReport = false;

  Future<void> _handleDownload({required bool isPdf}) async {
    final internship = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => const InternshipSelectorModal(),
    );
    if (internship == null) return;

    setState(() {
      if (isPdf) _isDownloadingPdf = true;
      else      _isGeneratingReport = true;
    });

    try {
      if (isPdf) {
        await DownloadService.downloadLogbookPdf(
          context,
          internshipId: internship['id'] as int,
        );
      } else {
        await DownloadService.downloadInternshipReport(
          context,
          internshipId: internship['id'] as int,
        );
      }
    } finally {
      setState(() {
        _isDownloadingPdf = false;
        _isGeneratingReport = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return WillPopScope(
      onWillPop: () async {
        context.go('/user/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Download Reports',
            style: AppTypography.headerTitle.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/user/dashboard'),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.itemPadding),
            child: Column(
              children: [
                Text('Available Downloads',
                    style: AppTypography.headline,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Download your documents and reports',
                  style:
                  AppTypography.subtitle.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                DownloadCard(
                  title: 'Download Logbook (PDF)',
                  description: 'Save your completed logbook as a PDF.',
                  icon: Icons.book,
                  fileExtension: 'pdf',
                  isLoading: _isDownloadingPdf,
                  onPressed: () => _handleDownload(isPdf: true),
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                DownloadCard(
                  title: 'Download Internship Report (DOCX)',
                  description: 'Generate and download your internship report.',
                  icon: Icons.assignment,
                  fileExtension: 'docx',
                  isLoading: _isGeneratingReport,
                  onPressed: () => _handleDownload(isPdf: false),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          role: widget.role ?? 'student',
          currentIndex: 2,
        ),
      ),
    );
  }
}
