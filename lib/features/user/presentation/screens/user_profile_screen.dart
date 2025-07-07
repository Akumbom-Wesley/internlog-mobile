import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/features/auth/presentation/widgets/bottom_navigation_bar.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/user_profile_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  final int? userId;
  const UserProfileScreen({super.key, this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final DioClient _dioClient = DioClient(); // Add this line
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isCurrentUser = true;
  String? _userRole;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = await _dioClient.getCurrentUserId();
      final result = await _profileService.fetchUserData(
        widget.userId ?? currentUserId,
      );

      setState(() {
        _userData = result['userData'];
        _isCurrentUser = result['isCurrentUser'];
        _userRole = result['userRole'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.userId == null
                ? 'Failed to load your profile: ${e.toString()}'
                : 'Failed to load user profile: ${e.toString()}',
            style: AppTypography.caption,
          ),
          backgroundColor: AppColors.error.withOpacity(0.1),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDecorations.backgroundGradient.colors.last,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.headerTitle,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: AppColors.primary.withOpacity(0.2),
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.go('/auth/logout');
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _userData == null
          ? Center(
        child: Container(
          decoration: AppDecorations.card,
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: AppConstants.iconSizeLarge,
                color: AppColors.error,
              ),
              const SizedBox(height: AppConstants.itemSpacing),
              Text(
                'No user data available',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppConstants.sectionSpacing),
              ElevatedButton.icon(
                style: AppWidgetStyles.elevatedButton,
                onPressed: _fetchUserData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.sectionSpacing),
              child: UserProfileWidgets.buildProfileHeader(
                userData: _userData!,
                isCurrentUser: _isCurrentUser,
                context: context,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.sectionSpacing),
                child: Column(
                  children: [
                    UserProfileWidgets.buildInfoCard(
                      'Contact Information',
                      [
                        UserProfileWidgets.buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: _userData!['email'] ?? 'Not provided',
                          iconColor: AppColors.info,
                        ),
                        UserProfileWidgets.buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: _userData!['contact'] ?? 'Not provided',
                          iconColor: AppColors.approved,
                        ),
                      ],
                    ),
                    if (_userData!['role'] == 'student' && _userData!['student'] != null)
                      UserProfileWidgets.buildInfoCard(
                        'Academic Information',
                        [
                          UserProfileWidgets.buildInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Matricule Number',
                            value: _userData!['student']['matricule_num'] ?? 'Not provided',
                            iconColor: AppColors.primary,
                          ),
                          UserProfileWidgets.buildInfoRow(
                            icon: Icons.school_outlined,
                            label: 'Department',
                            value: _userData!['student']['department']?['name'] ?? 'Not provided',
                            iconColor: AppColors.activity,
                          ),
                        ],
                      ),
                    if (_userData!['role'] == 'supervisor' && _userData!['supervisor'] != null)
                      UserProfileWidgets.buildInfoCard(
                        'Professional Information',
                        [
                          UserProfileWidgets.buildInfoRow(
                            icon: Icons.business_outlined,
                            label: 'Company',
                            value: _userData!['supervisor']['company']?['name'] ?? 'Not provided',
                            iconColor: AppColors.pending,
                          ),
                          UserProfileWidgets.buildInfoRow(
                            icon: Icons.verified_outlined,
                            label: 'Status',
                            value: _userData!['supervisor']['status'] ?? 'Not provided',
                            iconColor: AppColors.approved,
                          ),
                        ],
                      ),
                    if (_userData!['role'] == 'company_admin' && _userData!['company_admin'] != null)
                      UserProfileWidgets.buildInfoCard(
                        'Company Information',
                        [
                          UserProfileWidgets.buildInfoRow(
                            icon: Icons.business_center_outlined,
                            label: 'Company',
                            value: _userData!['company_admin']['company']?['name'] ?? 'Not provided',
                            iconColor: AppColors.activity,
                          ),
                        ],
                      ),
                    const SizedBox(height: AppConstants.sectionSpacing * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isCurrentUser
          ? BottomNavBar(
        role: _userRole ?? 'student', // Default to 'student' if null
        currentIndex: _currentIndex, // Reflects profile tab
      )
          : null,
    );
  }
}