import 'package:flutter/material.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/constants.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/widget_styles.dart';
import 'company_dashboard_widget.dart';

class InternshipRequestItem extends StatefulWidget {
  final dynamic request;
  final int iconColorIndex;
  final VoidCallback onRequestProcessed;
  final Future<List<dynamic>> Function(String) getSupervisors;
  final Future<void> Function(int, int) approveRequest;
  final Future<void> Function(int) rejectRequest;

  const InternshipRequestItem({
    super.key,
    required this.request,
    required this.iconColorIndex,
    required this.onRequestProcessed,
    required this.getSupervisors,
    required this.approveRequest,
    required this.rejectRequest,
  });

  @override
  _InternshipRequestItemState createState() => _InternshipRequestItemState();
}

class _InternshipRequestItemState extends State<InternshipRequestItem> {
  bool _isApproving = false;
  bool _isRejecting = false;

  Future<void> _approveRequest() async {
    setState(() => _isApproving = true);
    try {
      final userData = await DioClient().getCurrentUser();
      final companyId = userData['company_admin']?['company']?['id']?.toString();
      if (companyId == null) throw Exception('Company ID not found');

      final supervisors = await widget.getSupervisors(companyId);
      setState(() => _isApproving = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) {
            int? selectedSupervisorId = supervisors.isNotEmpty
                ? int.tryParse(supervisors.first['id'].toString())
                : null;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(
                    'Select Supervisor',
                    style: AppTypography.headline,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: AppWidgetStyles.inputDecoration.copyWith(
                          labelText: 'Supervisor',
                        ),
                        value: selectedSupervisorId,
                        items: supervisors.map<DropdownMenuItem<int>>((sup) {
                          return DropdownMenuItem<int>(
                            value: int.parse(sup['id'].toString()),
                            child: Text(
                              sup['user_name'],
                              style: AppTypography.body,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedSupervisorId = value);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: AppTypography.button),
                    ),
                    ElevatedButton(
                      style: AppWidgetStyles.elevatedButton,
                      onPressed: () async {
                        if (selectedSupervisorId == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Please select a supervisor', style: AppTypography.caption),
                              backgroundColor: AppColors.error.withOpacity(0.1),
                            ),
                          );
                          return;
                        }

                        try {
                          final requestId = int.tryParse(widget.request['id'].toString()) ?? 0;
                          if (requestId == 0) throw Exception('Invalid request ID');

                          await widget.approveRequest(requestId, selectedSupervisorId!);
                          widget.onRequestProcessed();
                          if (context.mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Request approved successfully', style: AppTypography.caption),
                              backgroundColor: AppColors.success.withOpacity(0.1),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Error approving request: $e', style: AppTypography.caption),
                              backgroundColor: AppColors.error.withOpacity(0.1),
                            ),
                          );
                        }
                      },
                      child: Text('Approve', style: AppTypography.button),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      setState(() => _isApproving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching supervisors: $e', style: AppTypography.caption),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
    }
  }

  Future<void> _rejectRequest() async {
    setState(() => _isRejecting = true);
    try {
      final requestId = int.tryParse(widget.request['id'].toString()) ?? 0;
      if (requestId == 0) throw Exception('Invalid request ID');
      await widget.rejectRequest(requestId);
      widget.onRequestProcessed();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request rejected successfully', style: AppTypography.caption),
          backgroundColor: AppColors.success.withOpacity(0.1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting request: $e', style: AppTypography.caption),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.iconColors[widget.iconColorIndex % AppColors.iconColors.length];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.itemSpacing),
      padding: const EdgeInsets.all(AppConstants.itemPadding),
      decoration: AppDecorations.itemCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request['student']?.toString() ?? 'Unknown Student',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          CompanyDashboardWidgets.buildDetailRow(
            icon: Icons.date_range,
            label: 'Proposed Dates',
            value:
            '${widget.request['start_date'] != null ? widget.request['start_date'].toString().split('T')[0] : 'Not available'} - ${widget.request['end_date'] != null ? widget.request['end_date'].toString().split('T')[0] : 'Not available'}',
            iconColor: iconColor,
          ),
          const SizedBox(height: AppConstants.itemSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: AppWidgetStyles.elevatedButton.copyWith(
                  backgroundColor: WidgetStateProperty.all(AppColors.approved),
                ),
                onPressed: _isApproving ? null : _approveRequest,
                child: _isApproving
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Approve',
                  style: AppTypography.button,
                ),
              ),
              const SizedBox(width: AppConstants.itemSpacing),
              ElevatedButton(
                style: AppWidgetStyles.elevatedButton.copyWith(
                  backgroundColor: WidgetStateProperty.all(AppColors.error),
                ),
                onPressed: _isRejecting ? null : _rejectRequest,
                child: _isRejecting
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Reject',
                  style: AppTypography.button,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}