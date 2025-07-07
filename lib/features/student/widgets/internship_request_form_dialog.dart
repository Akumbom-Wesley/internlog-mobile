import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';

class InternshipRequestFormDialog extends StatefulWidget {
  final VoidCallback onSubmitSuccess;

  const InternshipRequestFormDialog({super.key, required this.onSubmitSuccess});

  @override
  _InternshipRequestFormDialogState createState() => _InternshipRequestFormDialogState();
}

class _InternshipRequestFormDialogState extends State<InternshipRequestFormDialog> {
  List<dynamic> _companies = [];
  List<dynamic> _academicYears = [];
  bool _isLoading = true;
  String? _selectedCompany;
  String? _selectedAcademicYear;
  DateTime? _startDate;
  DateTime? _endDate;
  String _jobDescription = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dioClient = DioClient();
      final companiesList = await dioClient.get('api/companies/list');
      final academicYearsList = await dioClient.get('api/academic-years/list');
      setState(() {
        _companies = List<dynamic>.from(companiesList);
        _academicYears = List<dynamic>.from(academicYearsList);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load form data: $e',
              style: AppTypography.caption,
            ),
            backgroundColor: AppColors.error.withOpacity(0.1),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedCompany == null ||
        _selectedAcademicYear == null ||
        _startDate == null ||
        _endDate == null ||
        _jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields.',
            style: AppTypography.caption,
          ),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
      return;
    }

    try {
      final dioClient = DioClient();
      await dioClient.post('api/students/requests/create/', data: {
        'company': _selectedCompany,
        'academic_year': _selectedAcademicYear,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'job_description': _jobDescription,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Internship request sent successfully.',
            style: AppTypography.caption,
          ),
          backgroundColor: AppColors.success.withOpacity(0.1),
        ),
      );

      Navigator.of(context).pop();
      widget.onSubmitSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send request: $e',
            style: AppTypography.caption,
          ),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      title: Text('Internship Request', style: AppTypography.headline),
      content: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: AppWidgetStyles.inputDecoration.copyWith(labelText: 'Company'),
              items: _companies.map((company) {
                return DropdownMenuItem(
                  value: company['id'].toString(),
                  child: Text(company['name'], style: AppTypography.body),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCompany = value),
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            DropdownButtonFormField<String>(
              decoration: AppWidgetStyles.inputDecoration.copyWith(labelText: 'Academic Year'),
              items: _academicYears.map((year) {
                return DropdownMenuItem(
                  value: year['id'].toString(),
                  child: Text(year['label'], style: AppTypography.body),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAcademicYear = value),
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            ListTile(
              title: Text('Start Date', style: AppTypography.body),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('yyyy-MM-dd').format(_startDate!)
                    : 'Select date',
                style: AppTypography.subtitle,
              ),
              trailing: Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),
            ListTile(
              title: Text('End Date', style: AppTypography.body),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : 'Select date',
                style: AppTypography.subtitle,
              ),
              trailing: Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _endDate = date);
              },
            ),
            const SizedBox(height: AppConstants.itemSpacing),
            TextFormField(
              decoration: AppWidgetStyles.inputDecoration.copyWith(labelText: 'Job Description'),
              maxLines: 3,
              onChanged: (value) => _jobDescription = value,
              style: AppTypography.body,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
        ElevatedButton(
          onPressed: _submitRequest,
          style: AppWidgetStyles.elevatedButton,
          child: Text('Submit', style: AppTypography.button),
        ),
      ],
    );
  }
}