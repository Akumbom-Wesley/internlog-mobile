import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/decorations.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/theme/widget_styles.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DioClient _dioClient = DioClient();
  final _form = FormGroup({
    'email': FormControl<String>(validators: [
      Validators.required,
      Validators.email,
    ]),
    'password': FormControl<String>(validators: [
      Validators.required,
    ]),
  });

  Future<void> _onLoginPressed() async {
    if (_form.valid) {
      try {
        final email = _form.control('email').value as String;
        final password = _form.control('password').value as String;
        await _dioClient.login(email, password);
        final userData = await _dioClient.getCurrentUser();
        final role = userData['role'];
        if (role == 'user' || role == null) {
          context.go('/auth/select-role');
        } else {
          context.go('/user/dashboard', extra: role);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } else {
      _form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.1,
                    vertical: constraints.maxHeight * 0.05,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.app_registration,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppConstants.itemSpacing),
                      Text(
                        'InternLog',
                        style: AppTypography.headline.copyWith(
                          fontSize: 32,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.sectionSpacing),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Card(
                          elevation: 4,
                          shape: AppDecorations.cardShape,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.cardPadding,
                              vertical: AppConstants.cardPadding * 1.6,
                            ),
                            child: ReactiveForm(
                              formGroup: _form,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Login',
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 28,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing * 1.5),
                                  ReactiveTextField(
                                    formControlName: 'email',
                                    decoration: AppWidgetStyles.inputDecoration.copyWith(
                                      labelText: 'Email',
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Email is required',
                                      'email': (_) => 'Enter a valid email',
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing),
                                  ReactiveTextField(
                                    formControlName: 'password',
                                    obscureText: true,
                                    decoration: AppWidgetStyles.inputDecoration.copyWith(
                                      labelText: 'Password',
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Password is required',
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing * 1.5),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _onLoginPressed,
                                      style: AppWidgetStyles.elevatedButton.copyWith(
                                        padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: AppTypography.button.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Don’t have an account? ',
                                        style: AppTypography.subtitle.copyWith(fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.go('/auth/register');
                                        },
                                        child: Text(
                                          'Sign In',
                                          style: AppTypography.subtitle.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}