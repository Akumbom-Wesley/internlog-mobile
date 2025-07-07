import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/presentation/widgets/bottom_navigation_bar.dart';

class LogEntriesScreen extends StatefulWidget {
  final int weeklyLogId;
  final String? role;
  const LogEntriesScreen({super.key, required this.weeklyLogId, this.role});

  @override
  State<LogEntriesScreen> createState() => _LogEntriesScreenState();
}

class _LogEntriesScreenState extends State<LogEntriesScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _entries = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fetchEntries();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchEntries() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient();
      final data = await dio.get('api/logbook-entries/${widget.weeklyLogId}/list/');
      setState(() => _entries = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading entries: $e',
            style: AppTypography.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateEntryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEntryModal(
        weeklyLogId: widget.weeklyLogId,
        onEntryCreated: _fetchEntries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isStudent = widget.role == null || widget.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log Entries',
          style: AppTypography.headerTitle.copyWith(color: primaryColor),
        ),
        centerTitle: true,
        leading: BackButton(onPressed: () => context.pop()),
        actions: const [SizedBox(width: 48)],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _entries.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: AppConstants.iconSizeLarge,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppConstants.itemSpacing),
              Text(
                'No log entries found.',
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isStudent) ...[
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  'Tap the + button to create your first entry',
                  style: AppTypography.subtitle.copyWith(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        )
            : ListView.builder(
          itemCount: _entries.length,
          padding: const EdgeInsets.all(AppConstants.itemPadding),
          itemBuilder: (context, index) {
            final entry = _entries[index];
            final description = entry['description'] ?? 'No description';
            final feedback = entry['feedback'] ?? '';
            final hasFeedback = feedback.isNotEmpty;

            final truncatedDescription = description.length > 100
                ? '${description.substring(0, 100)}...'
                : description;

            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.itemPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncatedDescription,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.itemSpacing),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.itemPadding),
                          decoration: AppDecorations.itemCard.copyWith(
                            color: hasFeedback ? AppColors.approved.withOpacity(0.05) : AppColors.primary.withOpacity(0.05),
                            border: Border.all(
                              color: hasFeedback ? AppColors.approved.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.feedback_outlined,
                                size: 16,
                                color: hasFeedback ? AppColors.approved : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Feedback:',
                                      style: AppTypography.subtitle.copyWith(
                                        color: hasFeedback ? AppColors.approved : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasFeedback ? feedback : 'No feedback from supervisor',
                                      style: AppTypography.body.copyWith(
                                        color: hasFeedback ? AppColors.approved.shade800 : AppColors.primary.shade800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.go('/user/logbook/entry/${entry['id']}');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'See Full Entry',
                              style: AppTypography.button.copyWith(color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: isStudent
          ? FloatingActionButton(
        onPressed: _showCreateEntryModal,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavBar(
        role: widget.role ?? 'student',
        currentIndex: 1,
      ),
    );
  }
}

class CreateEntryModal extends StatefulWidget {
  final int weeklyLogId;
  final VoidCallback onEntryCreated;

  const CreateEntryModal({
    super.key,
    required this.weeklyLogId,
    required this.onEntryCreated,
  });

  @override
  State<CreateEntryModal> createState() => _CreateEntryModalState();
}

class _CreateEntryModalState extends State<CreateEntryModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error taking photo: $e';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dio = DioClient();
      final formData = FormData.fromMap({
        'description': _descriptionController.text.trim(),
        'weekly_log': widget.weeklyLogId,
      });

      if (_selectedImages.isNotEmpty) {
        for (int i = 0; i < _selectedImages.length; i++) {
          final file = _selectedImages[i];
          formData.files.add(MapEntry(
            'photos',
            await MultipartFile.fromFile(
              file.path,
              filename: 'image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ));
        }
      }

      await dio.post('api/logbook-entries/add/', data: formData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Log entry created successfully!',
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.approved,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
            duration: const Duration(seconds: 3),
          ),
        );
        widget.onEntryCreated();
      }
    } catch (e) {
      String errorMessage = 'Failed to create log entry. Please try again.';

      if (e is DioException && e.response?.data is Map) {
        final errors = e.response!.data as Map;
        if (errors.containsKey('non_field_errors')) {
          errorMessage = errors['non_field_errors'][0];
          if (errorMessage == 'Cannot add more than 5 log entries per week.') {
            errorMessage = 'You have reached the maximum of 5 log entries for this week.';
          }
        } else if (errors.containsKey('detail')) {
          errorMessage = errors['detail'];
        } else {
          final fieldErrors = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors.add('$key: ${value[0]}');
            }
          });
          if (fieldErrors.isNotEmpty) {
            errorMessage = fieldErrors.join(', ');
          }
        }
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusLarge)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.itemPadding),
            child: Row(
              children: [
                Text(
                  'Create New Entry',
                  style: AppTypography.headline,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.itemPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description *',
                      style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppConstants.itemSpacing),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: AppWidgetStyles.inputDecoration.copyWith(
                        hintText: 'Enter your log entry description...',
                        hintStyle: AppTypography.subtitle.copyWith(color: Colors.grey[500]),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description cannot be empty';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),
                    Text(
                      'Photos (Optional)',
                      style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppConstants.itemSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library),
                            label: Text('Gallery', style: AppTypography.button),
                            style: AppWidgetStyles.outlinedButton,
                          ),
                        ),
                        const SizedBox(width: AppConstants.itemSpacing),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: Text('Camera', style: AppTypography.button),
                            style: AppWidgetStyles.outlinedButton,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.itemSpacing),
                      Text(
                        'Selected Images (${_selectedImages.length})',
                        style: AppTypography.subtitle.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: AppConstants.itemSpacing),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppConstants.itemSpacing),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.itemPadding),
                        decoration: AppDecorations.errorContainer,
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.sectionSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitEntry,
                        style: AppWidgetStyles.elevatedButton,
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Create Entry',
                          style: AppTypography.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}