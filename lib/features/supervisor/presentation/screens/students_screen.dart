import 'package:flutter/material.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/core/theme/decorations.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';

import '../../../student/services/students_service.dart';
import '../../../student/widgets/students_widgets.dart';

class StudentsScreen extends StatefulWidget {
  final String role;
  const StudentsScreen({super.key, required this.role});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentsService _studentsService = StudentsService();
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final result = await _studentsService.fetchAssignedStudents();
      if (mounted) {
        setState(() {
          students = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'My Students',
            style: AppTypography.headerTitle.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StudentsWidgets.buildHeader(students.length, _fetchStudents),
              const SizedBox(height: 16),
              Expanded(
                child: students.isEmpty
                    ? StudentsWidgets.buildEmptyState()
                    : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) => StudentsWidgets.buildStudentCard(
                    students[index] as Map<String, dynamic>,
                    _studentsService,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          role: widget.role,
          currentIndex: 1,
        ),
      ),
    );
  }
}