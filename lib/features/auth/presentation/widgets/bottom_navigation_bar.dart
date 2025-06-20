// lib/features/user/presentation/screens/bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final String? role;
  final int currentIndex;

  const BottomNavBar({super.key, this.role, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final items = role == 'student'
        ? [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Logbook',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ]
        : [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Students',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      selectedItemColor: primaryColor, // Uses the same primary color as login screen
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        // Handle navigation based on index and role
        if (role == 'student') {
          switch (index) {
            case 0:
              context.go('/user/dashboard');
              break;
            case 1:
              context.go('/user/logbook');
              break;
            case 2:
              context.go('/user/profile');
              break;
          }
        } else if (role == 'supervisor') {
          switch (index) {
            case 0:
              context.go('/user/dashboard');
              break;
            case 1:
              context.go('/user/students');
              break;
            case 2:
              context.go('/user/settings');
              break;
          }
        }
      },
    );
  }
}