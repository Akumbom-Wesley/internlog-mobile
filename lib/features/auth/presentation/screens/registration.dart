import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internlog/core/network/dio_client.dart';

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
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: const TextStyle(color: Colors.red)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
          const SnackBar(content: Text('Registration successful!')),
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
        SystemNavigator.pop(); // Close the app
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
                      const Icon(
                        Icons.app_registration,
                        size: 60,
                        color: Color(0xFF1A237E),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'InternLog',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                            child: ReactiveForm(
                              formGroup: _form,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Register',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ReactiveTextField(
                                    formControlName: 'full_name',
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      labelStyle: GoogleFonts.poppins(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Full name is required',
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ReactiveTextField(
                                    formControlName: 'email',
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: GoogleFonts.poppins(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Email is required',
                                      'email': (_) => 'Enter a valid email',
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ReactiveTextField(
                                    formControlName: 'contact',
                                    decoration: InputDecoration(
                                      labelText: 'Contact',
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelStyle: GoogleFonts.poppins(),
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(left: 12.0, right: 4.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '🇨🇲 +237 ',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validationMessages: {
                                      'required': (_) => 'Contact is required',
                                      'pattern': (_) => 'Invalid contact format. Check number of digits.',
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ReactiveTextField(
                                    formControlName: 'password',
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: GoogleFonts.poppins(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Password is required',
                                      'minLength': (_) => 'Password must be at least 6 characters',
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ReactiveTextField(
                                    formControlName: 'confirm_password',
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: GoogleFonts.poppins(),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validationMessages: {
                                      'required': (_) => 'Please confirm your password',
                                      'mustMatch': (_) => 'Passwords do not match',
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _onRegisterPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        textStyle: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.go('/auth/login');
                                        },
                                        child: Text(
                                          'Login',
                                          style: GoogleFonts.poppins(
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