// lib/widgets/internship_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class InternshipCard extends StatelessWidget {
  final Map<String, dynamic> internship;

  const InternshipCard({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    final company = internship['company'] ?? 'Unknown';
    final status = internship['status'] ?? 'Pending';
    final startDate = internship['start_date'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(internship['start_date']))
        : '';
    final endDate = internship['end_date'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(internship['end_date']))
        : '';

    Color statusColor = _getStatusColor(status);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    company,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Start Date: ',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
                Text(
                  startDate,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'End Date: ',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
                Text(
                  endDate,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: statusColor,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.4, end: 0);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return Colors.orange; // Pending equivalent
      case 'ongoing':
        return Colors.green; // Approved equivalent
      case 'completed':
        return Colors.blue; // Completed
      case 'cancelled':
        return Colors.red; // Rejected equivalent
      default:
        return Colors.grey;
    }
  }
}