import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  // Map backend role value to a friendly label
  String getRoleLabel(String role) {
    const roleLabels = {
      'user': 'User',
      'student': 'Student',
      'lecturer': 'Lecturer',
      'supervisor': 'Supervisor',
      'company_admin': 'Company Admin',
      'super_admin': 'Super Admin',
    };
    return roleLabels[role] ?? (role.isNotEmpty
        ? role[0].toUpperCase() + role.substring(1).replaceAll('_', ' ')
        : 'Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = getRoleLabel(role);

    return WillPopScope(
      onWillPop: () async {
        // Exit the app when back pressed on dashboard
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$roleLabel Dashboard', style: GoogleFonts.poppins()),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the $roleLabel Dashboard!',
                style: GoogleFonts.poppins(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/user/profile'),
                icon: const Icon(Icons.person_outline),
                label: const Text('View Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
