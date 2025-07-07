import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';
import '../widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final DioClient _dioClient = DioClient();
  final _studentForm = FormGroup({
    'matriculeNum': FormControl<String>(value: null),
    'departmentId': FormControl<int>(value: null),
  });

  final _supervisorForm = FormGroup({
    'companyId': FormControl<int>(value: null),
  });

  String? _selectedRole;
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final deptResponse = await _dioClient.get('api/departments/list');
      _departments = List<Map<String, dynamic>>.from(deptResponse);

      final companyResponse = await _dioClient.get('api/companies/list');
      _companies = List<Map<String, dynamic>>.from(companyResponse);
    } catch (e) {
      _showErrorDialog('Failed to load data. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: AppTypography.headline.copyWith(color: AppColors.error)),
        content: Text(message, style: AppTypography.body.copyWith(color: AppColors.error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  void _resetForms() {
    _studentForm.reset();
    _supervisorForm.reset();
    setState(() => _selectedRole = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Select Your Role',
                      style: AppTypography.headline.copyWith(
                        fontSize: constraints.maxWidth * 0.08,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing * 1.5),
                  RoleCard(
                    title: 'Student',
                    isSelected: _selectedRole == 'student',
                    leadingIcon: Icon(Icons.school, size: 40, color: AppColors.info),
                    content: Column(
                      children: [
                        ReactiveForm(
                          formGroup: _studentForm,
                          child: Column(
                            children: [
                              ReactiveTextField(
                                formControlName: 'matriculeNum',
                                decoration: AppWidgetStyles.inputDecoration.copyWith(
                                  labelText: 'Matricule Number',
                                  hintText: 'UBa25E0001',
                                ),
                              ),
                              const SizedBox(height: AppConstants.itemSpacing),
                              ReactiveDropdownField<int>(
                                formControlName: 'departmentId',
                                items: [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('Select Department', style: AppTypography.body),
                                  ),
                                  ..._departments.map((dept) {
                                    return DropdownMenuItem<int>(
                                      value: dept['id'],
                                      child: Text('${dept['name']} - ${dept['school']['name']}',
                                          style: AppTypography.body),
                                    );
                                  }),
                                ],
                                decoration: AppWidgetStyles.inputDecoration.copyWith(
                                  labelText: 'Department',
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedRole == 'student') ...[
                          const SizedBox(height: AppConstants.sectionSpacing),
                          TextButton(
                            onPressed: _resetForms,
                            child: Text(
                              'Cancel Student Selection',
                              style: AppTypography.button.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRole = 'student';
                        _supervisorForm.reset();
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing),
                  RoleCard(
                    title: 'Supervisor',
                    isSelected: _selectedRole == 'supervisor',
                    leadingIcon: Icon(Icons.business, size: 40, color: AppColors.success),
                    content: Column(
                      children: [
                        ReactiveForm(
                          formGroup: _supervisorForm,
                          child: ReactiveDropdownField<int>(
                            formControlName: 'companyId',
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('Select Company', style: AppTypography.body),
                              ),
                              ..._companies.map((company) {
                                return DropdownMenuItem<int>(
                                  value: company['id'],
                                  child: Text(company['name'], style: AppTypography.body),
                                );
                              }),
                            ],
                            decoration: AppWidgetStyles.inputDecoration.copyWith(
                              labelText: 'Company',
                            ),
                          ),
                        ),
                        if (_selectedRole == 'supervisor') ...[
                          const SizedBox(height: AppConstants.sectionSpacing),
                          TextButton(
                            onPressed: _resetForms,
                            child: Text(
                              'Cancel Supervisor Selection',
                              style: AppTypography.button.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRole = 'supervisor';
                        _studentForm.reset();
                      });
                    },
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing * 2.5),
                  Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_selectedRole == null) {
                            _showErrorDialog('Please select a role first');
                            return;
                          }

                          try {
                            await _dioClient.selectRole(
                              role: _selectedRole!,
                              matriculeNum: _selectedRole == 'student'
                                  ? _studentForm.control('matriculeNum').value as String?
                                  : null,
                              departmentId: _selectedRole == 'student'
                                  ? _studentForm.control('departmentId').value as int?
                                  : null,
                              companyId: _selectedRole == 'supervisor'
                                  ? _supervisorForm.control('companyId').value as int?
                                  : null,
                            );
                            context.go('/user/profile');
                          } catch (e) {
                            _showErrorDialog('Role selection failed: $e');
                          }
                        },
                        style: AppWidgetStyles.elevatedButton.copyWith(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            ),
                          ),
                        ),
                        child: Text(
                          'CONFIRM ROLE',
                          style: AppTypography.button.copyWith(
                            fontSize: 18,
                          ),
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
    );
  }
}