import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';
import '../widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final DioClient _dioClient = DioClient();
  final _studentForm = FormGroup({
    'matriculeNum': FormControl<String>(value: null), // Nullable by default
    'departmentId': FormControl<int>(value: null), // Nullable by default
  });

  final _supervisorForm = FormGroup({
    'companyId': FormControl<int>(value: null), // Nullable by default
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
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: const TextStyle(color: Colors.red)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Select Your Role',
                      style: GoogleFonts.poppins(
                        fontSize: constraints.maxWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Student Role Card
                  RoleCard(
                    title: 'Student',
                    isSelected: _selectedRole == 'student',
                    leadingIcon: const Icon(Icons.school, size: 40, color: Colors.blue),
                    content: Column(
                      children: [
                        ReactiveForm(
                          formGroup: _studentForm,
                          child: Column(
                            children: [
                              ReactiveTextField(
                                formControlName: 'matriculeNum',
                                decoration: InputDecoration(
                                  labelText: 'Matricule Number',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: const OutlineInputBorder(),
                                  hintText: 'UBa25E0001',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ReactiveDropdownField<int>(
                                formControlName: 'departmentId',
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('Select Department'),
                                  ),
                                  ..._departments.map((dept) {
                                    return DropdownMenuItem<int>(
                                      value: dept['id'],
                                      child: Text('${dept['name']} - ${dept['school']['name']}'),
                                    );
                                  }),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Department',
                                  labelStyle: GoogleFonts.poppins(),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedRole == 'student') ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _resetForms,
                            child: Text(
                              'Cancel Student Selection',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
                  const SizedBox(height: 20),

                  // Supervisor Role Card
                  RoleCard(
                    title: 'Supervisor',
                    isSelected: _selectedRole == 'supervisor',
                    leadingIcon: const Icon(Icons.business, size: 40, color: Colors.green),
                    content: Column(
                      children: [
                        ReactiveForm(
                          formGroup: _supervisorForm,
                          child: ReactiveDropdownField<int>(
                            formControlName: 'companyId',
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Select Company'),
                              ),
                              ..._companies.map((company) {
                                return DropdownMenuItem<int>(
                                  value: company['id'],
                                  child: Text(company['name']),
                                );
                              }),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Company',
                              labelStyle: GoogleFonts.poppins(),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        if (_selectedRole == 'supervisor') ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _resetForms,
                            child: Text(
                              'Cancel Supervisor Selection',
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
                  const SizedBox(height: 40),

                  // Centralized OK Button
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CONFIRM ROLE',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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