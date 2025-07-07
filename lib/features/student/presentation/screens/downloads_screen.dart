import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/presentation/widgets/bottom_navigation_bar.dart';


class DownloadsScreen extends StatefulWidget {
  final String? role;

  const DownloadsScreen({super.key, this.role});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  static const String _baseUrl = 'http://10.140.91.152:8000';
  final DioClient _dioClient = DioClient();
  bool _isDownloading = false;

  Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      final dio = Dio();
      final directory = await getDownloadsDirectory();

      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      final savePath = '${directory.path}/$fileName';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: AppConstants.itemSpacing),
                Text('Downloading $fileName...', style: AppTypography.body),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await dio.download(url, savePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(child: Text('$fileName downloaded successfully!', style: AppTypography.body)),
              ],
            ),
            backgroundColor: AppColors.approved,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(child: Text('Download failed: ${e.toString()}', style: AppTypography.body)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download Reports',
          style: AppTypography.headerTitle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
        child: SingleChildScrollView( // Add this to handle overflow
          padding: const EdgeInsets.all(AppConstants.itemPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: [
              Text(
                'Available Downloads',
                style: AppTypography.headline,
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: 8),
              Text(
                'Download your documents and reports',
                style: AppTypography.subtitle.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center, // Center the text
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              ConstrainedBox( // Constrain card width
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: _buildDownloadCard(
                  title: 'Download Logbook',
                  description: 'Download your complete logbook in PDF format with all your daily activities and progress',
                  icon: Icons.book,
                  primaryColor: primaryColor,
                  fileUrl: '${_baseUrl}/api/logbooks/download/',
                  fileNamePrefix: 'logbook',
                  fileExtension: 'pdf',
                ),
              ),
              const SizedBox(height: AppConstants.itemSpacing),
              ConstrainedBox( // Constrain card width
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: _buildDownloadCard(
                  title: 'Download Internship Report',
                  description: 'Generate and download your official internship report in DOCX format',
                  icon: Icons.assignment,
                  primaryColor: primaryColor,
                  fileUrl: '${_baseUrl}/api/internships/',
                  fileNamePrefix: 'internship_report',
                  fileExtension: 'docx',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        role: widget.role ?? 'student',
        currentIndex: 2,
      ),
    );
  }

  Widget _buildDownloadCard({
    required String title,
    required String description,
    required IconData icon,
    required Color primaryColor,
    required String fileUrl,
    required String fileNamePrefix,
    required String fileExtension,
  }) {
    return Card(
      elevation: 8,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Container(
        decoration: AppDecorations.card,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.iconPadding),
                  decoration: AppDecorations.iconContainer,
                  child: Icon(
                    icon,
                    size: AppConstants.iconSizeLarge,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  title,
                  style: AppTypography.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.subtitle.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isDownloading
                        ? null
                        : () async {
                      try {
                        final internship = await _dioClient.getOngoingInternship();
                        final internshipId = internship['id'].toString();
                        await _downloadFile(
                          context: context,
                          url: '$fileUrl$internshipId${fileExtension == 'pdf' ? '' : '/generate-report/'}',
                          fileName: '$fileNamePrefix$internshipId.$fileExtension',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}', style: AppTypography.body),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: AppWidgetStyles.elevatedButton,
                    child: _isDownloading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppConstants.itemSpacing),
                        Text(
                          fileExtension == 'pdf' ? 'Downloading...' : 'Generating...',
                          style: AppTypography.button,
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(fileExtension == 'pdf' ? Icons.download : Icons.file_download, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          fileExtension == 'pdf' ? 'Download PDF' : 'Download Report',
                          style: AppTypography.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}