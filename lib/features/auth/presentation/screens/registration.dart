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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final DioClient _dioClient = DioClient();
  final _form = FormGroup({
    'full_name': FormControl<String>(validators: [Validators.required]),
    'email': FormControl<String>(validators: [Validators.required, Validators.email]),
    'contact': FormControl<String>(validators: [
      Validators.required,
      Validators.pattern(
        r'^6[245789]\d{7}$',
        validationMessage: 'Invalid contact format. Check number of digits.',
      ),
    ]),
    'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
    'confirm_password': FormControl<String>(validators: [Validators.required]),
  }, validators: [Validators.mustMatch('password', 'confirm_password')]);

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: AppTypography.headline.copyWith(color: AppColors.error)),
        content: Text(message, style: AppTypography.body.copyWith(color: AppColors.error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTypography.button),
          ),
        ],
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    if (_form.valid) {
      try {
        final rawContact = _form.control('contact').value as String;
        final contact = '+237$rawContact';

        await _dioClient.register(
          fullName: _form.control('full_name').value as String,
          email: _form.control('email').value as String,
          contact: contact,
          password: _form.control('password').value as String,
          confirmPassword: _form.control('confirm_password').value as String,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!', style: AppTypography.body)),
        );
        context.go('/auth/login');
      } catch (e) {
        if (e is Map<String, dynamic>) {
          String errorMessage = '';
          e.forEach((key, value) {
            if (value is List) {
              if (key == 'email' && value.contains('User with this email already exists.')) {
                errorMessage = 'Email already in use';
              } else if (key == 'contact' && value.contains('Invalid contact number format')) {
                errorMessage = 'Invalid contact format. Check number of digits';
              }
            }
          });
          if (errorMessage.isEmpty) errorMessage = 'Input all fields';
          _showErrorDialog(context, errorMessage);
        } else {
          _showErrorDialog(context, 'Registration failed');
        }
      }
    } else {
      _form.markAllAsTouched();
      _showErrorDialog(context, 'Input all fields');
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
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppConstants.itemSpacing),
                      Text(
                        'InternLog',
                        style: AppTypography.headline.copyWith(
                          fontSize: 24,
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
                              vertical: AppConstants.cardPadding,
                            ),
                            child: ReactiveForm(
                              formGroup: _form,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Register',
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 24,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing),
                                  ReactiveTextField(
                                    formControlName: 'full_name',
                                    decoration: AppWidgetStyles.inputDecoration.copyWith(
                                      labelText: 'Full Name',
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Full name is required',
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing),
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
                                    formControlName: 'contact',
                                    decoration: AppWidgetStyles.inputDecoration.copyWith(
                                      labelText: 'Contact',
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(left: 12.0, right: 4.0),
                                        child: Text(
                                          '🇨🇲 +237 ',
                                          style: AppTypography.caption,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validationMessages: {
                                      'required': (_) => 'Contact is required',
                                      'pattern': (_) => 'Invalid contact format. Check number of digits.',
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
                                      'minLength': (_) => 'Password must be at least 6 characters',
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing),
                                  ReactiveTextField(
                                    formControlName: 'confirm_password',
                                    obscureText: true,
                                    decoration: AppWidgetStyles.inputDecoration.copyWith(
                                      labelText: 'Confirm Password',
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Please confirm your password',
                                      'mustMatch': (_) => 'Passwords do not match',
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.sectionSpacing * 1.25),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _onRegisterPressed,
                                      style: AppWidgetStyles.elevatedButton.copyWith(
                                        padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                      child: Text(
                                        'Register',
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
                                        'Already have an account? ',
                                        style: AppTypography.subtitle.copyWith(fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.go('/auth/login');
                                        },
                                        child: Text(
                                          'Login',
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