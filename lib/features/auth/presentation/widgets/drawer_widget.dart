import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';

class DrawerWidget extends StatelessWidget {
  final Color primaryColor;

  const DrawerWidget({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header Section
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
                      color: primaryColor,
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
                            color: primaryColor,
                            fontSize: 14,
                          ),
                        );
                      }
                      final fullName = snapshot.data!['full_name'] ?? 'Unknown User';
                      return Text(
                        fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(context, Icons.work_outline, 'Internship Requests', '/apply-internship'),
                  _buildDrawerItem(context, Icons.history_outlined, 'Logbook History', '/past-logbooks'),
                  _buildDrawerItem(context, Icons.hourglass_empty_outlined, 'Pending Internships', '/pending-internships'),
                  _buildDrawerItem(context, Icons.settings_outlined, 'Settings', '/settings'),
                  _buildDrawerItem(context, Icons.store_mall_directory_outlined, 'View Companies', '/companies'),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(context, Icons.logout_outlined, 'Logout', '/auth/logout', isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        bool isDestructive = false,
      }) {
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
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
    );
  }
}
