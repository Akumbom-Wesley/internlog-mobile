import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/typography.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../../../supervisor/presentation/screens/supervisor_dashboard.dart';
import '../../../student/presentation/screens/student_dashboard.dart';
import '../../../company/presentation/screens/company_dashboard.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _role = 'student'; // Initialize with default value
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
        _role = userData['role'] ?? 'student'; // Provide fallback value
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
            style: AppTypography.headline.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: AppConstants.iconSizeLarge),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          backgroundColor: AppColors.primary,
        ),
        drawer: DrawerWidget(primaryColor: primaryColor),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _role == 'supervisor'
            ? SupervisorDashboard(role: _role)
            : _role == 'student'
            ? StudentDashboard(role: _role)
            : _role == 'company_admin'
            ? CompanyDashboard(role: _role)
            : Center(
          child: Text(
            'Welcome to the $_role Dashboard!',
            style: AppTypography.headline.copyWith(fontSize: 24),
          ),
        ),
        bottomNavigationBar: BottomNavBar(role: _role, currentIndex: 0),
      ),
    );
  }
}