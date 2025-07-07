import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';
import 'full_screen_image_viewer.dart';
import 'logentry_helpers.dart';

class LogEntryWidgets {
  static Widget buildErrorView({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        decoration: AppDecorations.card,
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeLarge,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            Text(
              errorMessage,
              style: AppTypography.body.copyWith(
                color: AppColors.primary.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.sectionSpacing),
            ElevatedButton(
              onPressed: onRetry,
              style: AppWidgetStyles.elevatedButton,
              child: Text(
                'Retry',
                style: AppTypography.button,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEntryDetails({
    required Map<String, dynamic> entry,
    required VoidCallback onEditPressed,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDescriptionSection(entry['description']),
          const SizedBox(height: AppConstants.sectionSpacing),
          buildFeedbackSection(entry['feedback']),
          const SizedBox(height: AppConstants.sectionSpacing),
          buildPhotosSection(entry['photos']),
          const SizedBox(height: AppConstants.sectionSpacing),
          buildCreatedAtSection(entry['created_at']),
          const SizedBox(height: AppConstants.sectionSpacing),
          buildEditButton(
            isImmutable: entry['is_immutable'] == true,
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }

  static Widget buildDescriptionSection(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTypography.headline,
        ),
        const SizedBox(height: AppConstants.itemSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          decoration: AppDecorations.card.copyWith(
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Text(
            description ?? 'No description',
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }

  static Widget buildFeedbackSection(String? feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback',
          style: AppTypography.headline,
        ),
        const SizedBox(height: AppConstants.itemSpacing),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          decoration: AppDecorations.card.copyWith(
            border: Border.all(color: AppColors.info.withOpacity(0.1)),
          ),
          child: Text(
            feedback?.isNotEmpty == true ? feedback! : 'No feedback from supervisor',
            style: AppTypography.body.copyWith(color: AppColors.info),
          ),
        ),
      ],
    );
  }

  static Widget buildPhotosSection(List<dynamic>? photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: AppTypography.headline,
        ),
        const SizedBox(height: AppConstants.itemSpacing),
        photos?.isNotEmpty == true
            ? buildPhotosList(photos!)
            : buildNoPhotosPlaceholder(),
      ],
    );
  }

  static Widget buildPhotosList(List<dynamic> photos) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppConstants.itemSpacing),
        itemBuilder: (context, index) {
          final photo = photos[index] as Map<String, dynamic>;
          final imageUrl = buildImageUrl(photo['photo'] ?? '');

          return GestureDetector(
            onTap: () => showFullScreenImage(context, imageUrl),
            child: Container(
              width: 180,
              height: 180,
              decoration: AppDecorations.card.copyWith(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.shade100,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.primary.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: AppConstants.iconSizeMedium,
                          color: AppColors.primary.shade500,
                        ),
                        const SizedBox(height: AppConstants.itemSpacing),
                        Text(
                          'Image not found',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget buildNoPhotosPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: AppDecorations.card.copyWith(
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        'No attached images',
        style: AppTypography.body.copyWith(
          color: AppColors.primary.shade700,
        ),
      ),
    );
  }

  static Widget buildCreatedAtSection(String? createdAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created On',
          style: AppTypography.headline,
        ),
        const SizedBox(height: AppConstants.itemSpacing),
        Text(
          createdAt != null ? formatDate(createdAt) : 'Not available',
          style: AppTypography.body.copyWith(
            color: AppColors.primary.shade700,
          ),
        ),
      ],
    );
  }

  static Widget buildEditButton({
    required bool isImmutable,
    required VoidCallback onPressed,
  }) {
    if (isImmutable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        decoration: AppDecorations.card.copyWith(
          border: Border.all(color: AppColors.pending.withOpacity(0.3)),
        ),
        child: Text(
          'This entry is approved and cannot be edited.',
          style: AppTypography.body.copyWith(
            color: AppColors.pending,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppWidgetStyles.elevatedButton,
        child: Text(
          'Edit Entry',
          style: AppTypography.button,
        ),
      ),
    );
  }
}