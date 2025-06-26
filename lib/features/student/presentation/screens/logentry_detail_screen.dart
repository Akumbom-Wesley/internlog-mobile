import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';

import '../../widgets/edit_entry_modal.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/logentry_helpers.dart';

class LogEntryDetailScreen extends StatefulWidget {
  final int entryId;
  final String? role;

  const LogEntryDetailScreen({super.key, required this.entryId, this.role});

  @override
  State<LogEntryDetailScreen> createState() => _LogEntryDetailScreenState();
}

class _LogEntryDetailScreenState extends State<LogEntryDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _entry;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEntry();
  }

  Future<void> _fetchEntry() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().get('api/logbook-entries/${widget.entryId}/');
      final entryData = parseEntryResponse(response);

      setState(() {
        _entry = entryData;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e is DioException && e.response?.statusCode == 404
            ? 'Log entry not found.'
            : 'Failed to load entry: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showEditEntryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditEntryModal(
        entryId: widget.entryId,
        initialDescription: _entry!['description'] ?? '',
        onEntryUpdated: _fetchEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log Entry Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_entry != null && _entry!['weekly_log'] != null) {
              context.go('/user/logbook/week/${_entry!['weekly_log']}');
            } else {
              context.go('/user/logbook');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildEntryDetails(),
      bottomNavigationBar: BottomNavBar(
        role: widget.role ?? 'student',
        currentIndex: 1,
      ),
    );
  }

  Widget _buildErrorView() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryDetails() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionSection(primaryColor),
          const SizedBox(height: 24),
          _buildFeedbackSection(primaryColor),
          const SizedBox(height: 24),
          _buildPhotosSection(primaryColor),
          const SizedBox(height: 24),
          _buildCreatedAtSection(primaryColor),
          const SizedBox(height: 24),
          _buildEditButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            _entry!['description'] ?? 'No description',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Text(
            _entry!['feedback']?.isNotEmpty == true
                ? _entry!['feedback']
                : 'No feedback from supervisor',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _entry!['photos']?.isNotEmpty == true
            ? _buildPhotosList()
            : _buildNoPhotosPlaceholder(),
      ],
    );
  }

  Widget _buildPhotosList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _entry!['photos'].length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final photo = _entry!['photos'][index];
          final imageUrl = buildImageUrl(photo['photo'] ?? '');

          return GestureDetector(
            onTap: () => showFullScreenImage(context, imageUrl),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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

  Widget _buildNoPhotosPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        'No attached images',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCreatedAtSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created On',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formatDate(_entry!['created_at']),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(Color primaryColor) {
    if (_entry!['is_immutable'] == true) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Text(
          'This entry is approved and cannot be edited.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.orange[800],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showEditEntryModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Edit Entry',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}