// lib/features/user/presentation/screens/log_entries_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';

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
        SnackBar(content: Text('Error loading entries: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Log Entries',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: const [SizedBox(width: 48)], // Balance the leading button
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No log entries found.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _entries.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final createdAt = _formatDate(entry['created_at'] ?? '');
          final description = entry['description'] ?? 'No description';
          final status = entry['status'] ?? 'pending_approval';
          final feedback = entry['feedback'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Handle entry tap if needed
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Created: $createdAt',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (feedback.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.feedback_outlined,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Feedback:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      feedback,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        role: widget.role ?? 'student',
        currentIndex: 1, // Logbook tab index (since this is part of logbook flow)
      ),
    );
  }
}