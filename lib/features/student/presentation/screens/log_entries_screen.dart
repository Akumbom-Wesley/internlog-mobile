// lib/features/user/presentation/screens/log_entries_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';

class LogEntriesScreen extends StatefulWidget {
  final int weeklyLogId;
  const LogEntriesScreen({super.key, required this.weeklyLogId});

  @override
  State<LogEntriesScreen> createState() => _LogEntriesScreenState();
}

class _LogEntriesScreenState extends State<LogEntriesScreen> {
  bool _isLoading = true;
  List<dynamic> _entries = [];

  @override
  void initState() {
    super.initState();
    _fetchEntries();
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
        title: Text('Log Entries', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Center(child: Text('No log entries found.', style: GoogleFonts.poppins(color: Colors.grey)))
          : ListView.separated(
        itemCount: _entries.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final createdAt = _formatDate(entry['created_at'] ?? '');
          final description = entry['description'] ?? 'No description';
          final status = entry['status'] ?? 'pending_approval';
          final feedback = entry['feedback'] ?? '';

          IconData icon;
          Color color;
          switch (status) {
            case 'approved':
              icon = Icons.check_circle;
              color = Colors.green;
              break;
            case 'rejected':
              icon = Icons.cancel;
              color = Colors.red;
              break;
            default:
              icon = Icons.hourglass_empty;
              color = Colors.orange;
          }

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(description, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Created: $createdAt', style: GoogleFonts.poppins(fontSize: 13)),
                if (feedback.isNotEmpty)
                  Text('Feedback: $feedback', style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {
              // Handle entry tap if needed
            },
          );
        },
      ),
    );
  }
}

