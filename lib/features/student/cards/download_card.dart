import 'package:flutter/material.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';

class DownloadCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String fileExtension;
  final bool isLoading;
  final VoidCallback onPressed;

  const DownloadCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.fileExtension,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
      child: Card(
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Container(
          decoration: AppDecorations.card,
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.iconPadding),
                decoration: AppDecorations.iconContainer,
                child: Icon(icon, size: AppConstants.iconSizeLarge, color: primaryColor),
              ),
              const SizedBox(height: AppConstants.itemSpacing),
              Text(title, style: AppTypography.headline, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(description, style: AppTypography.subtitle.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.sectionSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppWidgetStyles.elevatedButton,
                  onPressed: isLoading ? null : onPressed,
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppConstants.itemSpacing),
                      Text(
                        fileExtension == 'pdf' ? 'Downloading PDF...' : 'Generating Report...',
                        style: AppTypography.button,
                      ),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(fileExtension == 'pdf' ? Icons.download : Icons.file_download, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(fileExtension == 'pdf' ? 'Download PDF' : 'Download Report', style: AppTypography.button),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
