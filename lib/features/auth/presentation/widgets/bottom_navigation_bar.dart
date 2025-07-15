import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/theme/colors.dart';
import 'package:internlog/core/theme/typography.dart';
import 'package:internlog/features/company/services/company_dashboard_service.dart';

class BottomNavBar extends StatelessWidget {
  final String role;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.role,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (role == 'student') {
      return _buildStudentNavBar(context);
    } else if (role == 'company_admin') {
      return _buildCompanyNavBar(context);
    } else {
      return _buildSupervisorNavBar(context);
    }
  }

  BottomNavigationBar _buildStudentNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/user/dashboard');
            break;
          case 1:
            context.go('/user/logbook');
            break;
          case 2:
            context.go('/user/downloads');
            break;
          case 3:
            context.go('/user/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.primary.withOpacity(0.5),
      selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.caption,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Logbook',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_outlined),
          activeIcon: Icon(Icons.download),
          label: 'Downloads',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  BottomNavigationBar _buildCompanyNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) async {
        final route = GoRouter.of(context);
        final currentRoute = route.routerDelegate.currentConfiguration.uri.toString();
        final service = CompanyDashboardService();

        // Prevent navigation if already on the target route
        switch (index) {
          case 0:
            if (currentRoute == '/company/dashboard') return;
            context.go('/company/dashboard', extra: 'company_admin');
            break;
          case 1:
            if (currentRoute == '/company/internships') return;
            try {
              final result = await service.fetchCompanyData();
              context.go(
                '/company/internships',
                extra: {'internships': result['activeInternships'] ?? []},
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching internships: $e', style: AppTypography.caption),
                  backgroundColor: AppColors.error.withOpacity(0.1),
                ),
              );
            }
            break;
          case 2:
            if (currentRoute == '/company/requests') return;
            try {
              final result = await service.fetchCompanyData();
              context.go(
                '/company/requests',
                extra: {
                  'requests': result['pendingRequests'] ?? [],
                  'onRequestProcessed': () {}, // Placeholder; will be updated in Step 2
                },
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching requests: $e', style: AppTypography.caption),
                  backgroundColor: AppColors.error.withOpacity(0.1),
                ),
              );
            }
            break;
          case 3:
            if (currentRoute == '/user/profile') return;
            context.go('/user/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.primary.withOpacity(0.5),
      selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.caption,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Internships',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  BottomNavigationBar _buildSupervisorNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex.clamp(0, 2), // Ensure index is within valid range
      onTap: (index) {
        final route = GoRouter.of(context);
        final currentRoute = route.routerDelegate.currentConfiguration.uri.toString();

        switch (index) {
          case 0:
            if (currentRoute != '/user/dashboard') {
              context.go('/user/dashboard', extra: role);
            }
            break;
          case 1:
            if (currentRoute != '/supervisor/students') {
              context.go('/supervisor/students', extra: role);
            }
            break;
          case 2:
            if (currentRoute != '/user/profile') {
              context.go('/user/profile', extra: role);
            }
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.primary.withOpacity(0.5),
      selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.caption,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Students',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}