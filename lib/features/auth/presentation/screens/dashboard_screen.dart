import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:internlog/core/network/dio_client.dart';
import '../widgets/internship_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _role;
  List<dynamic> _internships = [];
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
      await _fetchInternships();
    } catch (e) {
      if (mounted) context.go('/auth/login');
    }
  }

  Future<void> _fetchInternships() async {
    setState(() => _isLoading = true);
    try {
      final dioClient = DioClient();
      _internships = await dioClient.getInternships(status: 'ongoing');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load internships: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$roleLabel Dashboard',
            style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        drawer: _buildDrawer(primaryColor),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _role == 'student'
            ? _internships.isEmpty
            ? Center(
          child: Text(
            'No ongoing internships found.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _internships.length,
          itemBuilder: (context, index) {
            return InternshipCard(internship: _internships[index]);
          },
        )
            : Center(
          child: Text(
            'Welcome to the $roleLabel Dashboard!',
            style: GoogleFonts.poppins(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(Color primaryColor) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.app_registration,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'InternLog',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -1, end: 0),
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, dynamic>>(
                    future: DioClient().getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          'Unknown User',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        );
                      }
                      final fullName = snapshot.data!['full_name'] ?? 'Unknown User';
                      return GestureDetector(
                        onTap: () => context.go('/user/profile'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.person, size: 16, color: primaryColor),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(Icons.work_outline, 'Internship Requests', '/apply-internship'),
                  _buildDrawerItem(Icons.history_outlined, 'Logbook History', '/past-logbooks'),
                  _buildDrawerItem(Icons.hourglass_empty_outlined, 'Pending Internships', '/pending-internships'),
                  _buildDrawerItem(Icons.settings_outlined, 'Settings', '/settings'),
                  _buildDrawerItem(Icons.store_mall_directory_outlined, 'View Companies', '/companies'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(Icons.logout_outlined, 'Logout', '/auth/logout', isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String route, {bool isDestructive = false}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final itemColor = isDestructive ? Colors.red.shade600 : primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: itemColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
        hoverColor: itemColor.withOpacity(0.05),
        splashColor: itemColor.withOpacity(0.1),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }
}