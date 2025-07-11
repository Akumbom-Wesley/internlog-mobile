// logentry_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';

import '../../services/log_entry_service.dart';
import '../../widgets/edit_entry_modal.dart';
import '../../widgets/log_entry_widget.dart';
import '../../widgets/logentry_helpers.dart';

class LogEntryDetailScreen extends StatefulWidget {
  final int entryId;
  final String? role;

  const LogEntryDetailScreen({super.key, required this.entryId, this.role});

  @override
  State<LogEntryDetailScreen> createState() => _LogEntryDetailScreenState();
}

class _LogEntryDetailScreenState extends State<LogEntryDetailScreen> {
  final LogEntryService _service = LogEntryService();
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
      final entryData = await _service.fetchEntry(widget.entryId);
      setState(() {
        _entry = entryData;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _service.handleError(e);
        _isLoading = false;
      });
    }
  }

  void _showEditEntryModal() {
    // Extract current photos data including IDs for potential deletion
    final currentPhotos = _entry!['photos'] as List<dynamic>? ?? [];
    final currentPhotoUrls = currentPhotos.map<String>((p) => p['photo'] as String).toList();
    final currentPhotoIds = currentPhotos.map<int>((p) => p['id'] as int).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditEntryModal(
        entryId: widget.entryId,
        initialDescription: _entry!['description'] ?? '',
        initialPhotos: currentPhotoUrls,
        currentPhotoIds: currentPhotoIds, // Pass the photo IDs
        onEntryUpdated: _fetchEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDecorations.backgroundGradient.colors.last,
      appBar: AppBar(
        title: Text(
          'Log Entry Details',
          style: AppTypography.headerTitle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_entry != null && _entry!['weekly_log'] != null) {
              context.go('/user/logbook/week/${_entry!['weekly_log']}');
            } else {
              context.go('/user/logbook');
            }
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
          ? LogEntryWidgets.buildErrorView(
        errorMessage: _errorMessage!,
        onRetry: _fetchEntry,
      )
          : LogEntryWidgets.buildEntryDetails(
        entry: _entry!,
        onEditPressed: _showEditEntryModal,
      ),
      bottomNavigationBar: BottomNavBar(
        role: widget.role ?? 'student',
        currentIndex: 1,
      ),
    );
  }
}