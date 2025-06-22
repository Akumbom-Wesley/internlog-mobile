// lib/features/user/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/dio_client.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'supervisor_dashboard.dart';
import '../../../student/presentation/screens/student_dashboard.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _role;
  bool _isLoading = true;

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
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth/login');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: primaryColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: DrawerWidget(primaryColor: primaryColor),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _role == 'supervisor'
            ? SupervisorDashboard()
            : _role == 'student'
            ? StudentDashboard()
            : Center(
          child: Text(
            'Welcome to the $_role Dashboard!',
            style: GoogleFonts.poppins(fontSize: 24),
          ),
        ),
        bottomNavigationBar: BottomNavBar(role: _role, currentIndex: 0),
      ),
    );
  }
}