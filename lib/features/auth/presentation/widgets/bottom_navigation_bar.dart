import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final String? role;
  final int currentIndex;

  const BottomNavBar({super.key, this.role, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final items = role == 'student'
        ? [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Logbook',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.download),
        label: 'Downloads',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ]
        : [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Students',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (role == 'student') {
          switch (index) {
            case 0:
              if (currentIndex != 0) {
                context.go('/user/dashboard');
              }
              break;
            case 1:
              if (currentIndex != 1) {
                context.go('/user/logbook');
              }
              break;
            case 2:
              if (currentIndex != 2) {
                context.go('/user/downloads');
              }
              break;
            case 3:
              if (currentIndex != 3) {
                context.go('/user/profile');
              }
              break;
          }
        } else if (role == 'supervisor') {
          switch (index) {
            case 0:
              if (currentIndex != 0) {
                context.go('/user/dashboard');
              }
              break;
            case 1:
              if (currentIndex != 1) {
                context.go('/user/students');
              }
              break;
            case 2:
              if (currentIndex != 2) {
                context.go('/user/settings');
              }
              break;
          }
        }
      },
    );
  }
}