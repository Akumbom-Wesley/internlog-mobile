import 'package:flutter/material.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/typography.dart';

class InternshipSelectorModal extends StatefulWidget {
  const InternshipSelectorModal({super.key});
  @override
  State<InternshipSelectorModal> createState() =>
      _InternshipSelectorModalState();
}

class _InternshipSelectorModalState extends State<InternshipSelectorModal> {
  final DioClient _dioClient = DioClient();
  List<dynamic> internships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInternships();
  }

  Future<void> _fetchInternships() async {
    try {
      final result =
      await _dioClient.get('api/internships/list?status=completed');
      if (mounted) {
        setState(() {
          internships = result as List<dynamic>;
          isLoading = false;
        });
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch internships: $e')),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child:
          Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: internships.length,
        itemBuilder: (ctx, i) {
          final item = internships[i] as Map<String, dynamic>;
          final companyName = (item['company'] is Map)
              ? (item['company']['name'] as String? ?? 'Unknown Company')
              : (item['company']?.toString() ?? 'Unknown Company');

          return ListTile(
            title: Text('Internship – $companyName',
                style: AppTypography.body),
            subtitle: Text(
              'From ${_formatDate(item['start_date'])} to ${_formatDate(item['end_date'])}',
            ),
            onTap: () => Navigator.pop(context, item),
          );
        },
      ),
    );
  }
}
