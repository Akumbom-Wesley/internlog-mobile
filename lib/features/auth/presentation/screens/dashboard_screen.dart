import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dioClient = DioClient();
      final userData = await dioClient.getCurrentUser();
      setState(() {
        _role = userData['role'];
      });
    } catch (e) {
      if (mounted) context.go('/auth/login');
    }
  }

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
    final roleLabel = _role != null ? getRoleLabel(_role!) : 'Dashboard';

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('$roleLabel Dashboard', style: GoogleFonts.poppins()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.go('/auth/logout'),
            ),
          ],
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