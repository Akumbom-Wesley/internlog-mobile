// // lib/features/user/presentation/screens/log_entry_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart';
// import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';
// import 'package:internlog/core/network/dio_client.dart';
//
// class LogEntryDetailScreen extends StatefulWidget {
//   final int entryId;
//   const LogEntryDetailScreen({super.key, required this.entryId});
//
//   @override
//   State<LogEntryDetailScreen> createState() => _LogEntryDetailScreenState();
// }
//
// class _LogEntryDetailScreenState extends State<LogEntryDetailScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _entry;
//   final _descController = TextEditingController();
//   final _feedbackController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchEntry();
//   }
//
//   Future<void> _fetchEntry() async {
//     setState(() => _isLoading = true);
//     try {
//       final dio = DioClient();
//       final rawData = await dio.get('api/logbook-entries/${widget.entryId}/');
//       final data = Map<String, dynamic>.from(rawData as Map);
//
//       setState(() {
//         _entry = data;
//         _descController.text = data['description'] ?? '';
//         _feedbackController.text = data['feedback'] ?? '';
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching entry: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _formatDate(String dateStr) {
//     try {
//       return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
//     } catch (_) {
//       return dateStr;
//     }
//   }
//
//   Future<void> _updateEntry() async {
//     try {
//       final dio = DioClient();
//       await dio.patch('api/logbook-entries/${widget.entryId}/', {
//         'description': _descController.text,
//         'feedback': _feedbackController.text,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Log entry updated')));
//       _fetchEntry(); // Refresh after update
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.colorScheme.primary;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Log Entry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//         leading: BackButton(onPressed: () => context.pop()),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _entry == null
//           ? Center(child: Text('No entry found'))
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (_entry!['is_immutable'] != true)
//                 ElevatedButton(
//                   onPressed: _updateEntry,
//                   child: const Text('Update Entry'),
//                 ),
//               const SizedBox(height: 16),
//               Text('Description', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _descController,
//                 maxLines: null,
//                 readOnly: _entry!['is_immutable'],
//                 decoration: const InputDecoration(hintText: 'Enter description'),
//               ),
//               const SizedBox(height: 16),
//               Text('Feedback', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _feedbackController,
//                 maxLines: null,
//                 readOnly: _entry!['is_immutable'],
//                 decoration: const InputDecoration(hintText: 'Enter feedback'),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Created: ${_formatDate(_entry!['created_at'])}',
//                 style: GoogleFonts.poppins(color: Colors.grey[700]),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(
//                     _entry!['is_immutable'] ? Icons.lock : Icons.lock_open,
//                     color: _entry!['is_immutable'] ? Colors.green : Colors.orange,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     _entry!['is_immutable'] ? 'Immutable' : 'Pending Approval',
//                     style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
