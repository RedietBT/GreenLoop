import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';

// Import your colors file
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';

class RegisterForIndividualBody extends StatefulWidget {
  final String role;
  const RegisterForIndividualBody({super.key, required this.role});

  @override
  State<RegisterForIndividualBody> createState() => _RegisterForIndividualBodyState();
}

class _RegisterForIndividualBodyState extends State<RegisterForIndividualBody> {
  final _formKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String? error;

  // Using colors from AppColors
  final Color primaryColorStart = AppColors.caribbeanGreen;
  final Color primaryColorEnd = AppColors.blueChill;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<RegisterForIndividualCubit, RegisterForIndividualState>(
        listener: (context, state) {
          if (state is RegisterForIndividualSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Registration successful. Please verify your email."),
                backgroundColor: Color.fromARGB(255, 228, 234, 228),
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pushReplacementNamed('/login');
            });
          }
        },
        child: BlocBuilder<RegisterForIndividualCubit, RegisterForIndividualState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Title with gradient text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryColorStart, primaryColorEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Register as ${widget.role}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.white, // color will be overridden by shader
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Fields with animation
                    _buildAnimatedTextField(
                      label: 'First Name',
                      onChanged: (val) => setState(() => firstName = val),
                      validator: (val) => val == null || val.isEmpty ? 'First name required' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildAnimatedTextField(
                      label: 'Last Name',
                      onChanged: (val) => setState(() => lastName = val),
                      validator: (val) => val == null || val.isEmpty ? 'Last name required' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildAnimatedTextField(
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => setState(() => email = val),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email required';
                        final emailRegex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
                            r"[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildAnimatedTextField(
                      label: 'Password',
                      obscureText: true,
                      onChanged: (val) => setState(() => password = val),
                      validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildAnimatedTextField(
                      label: 'Confirm Password',
                      obscureText: true,
                      onChanged: (val) => setState(() => confirmPassword = val),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Confirm your password';
                        if (val != password) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is RegisterForIndividualLoading ? null : _submit,
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(8),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return primaryColorStart.withOpacity(0.5);
                              }
                              return primaryColorStart;
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          shadowColor: MaterialStateProperty.all(primaryColorEnd.withOpacity(0.8)),
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: state is RegisterForIndividualLoading
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  "Register",
                                  key: ValueKey('text'),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: Text(
                            "have an account? Login here.",
                            style: TextStyle(
                              fontFamily: Fonts.fontFamily,
                              color: AppColors.mirage,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                    if (error != null)
                      _buildErrorRow(error!, icon: Icons.error, color: Colors.red),

                    if (state is RegisterForIndividualFailure)
                      _buildErrorRow(state.message ?? 'An unknown error occurred',
                          icon: Icons.error_outline, color: Colors.red),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorRow(String message, {required IconData icon, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    setState(() => error = null);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterForIndividualCubit>().registerIndividual(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            userType: widget.role,
          );
    }
  }

  Widget _buildAnimatedTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Focus(
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: hasFocus ? AppColors.mischka : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: primaryColorStart.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.mirage,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasFocus ? primaryColorStart : Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: primaryColorStart, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
            ),
          ),
        );
      }),
    );
  }
}
