import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart'; // Import your custom colors
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart'; // Note: Check 'preseniation' vs 'presentation' typo
import 'package:greenloop/src/auth/preseniation/views/register_as_page.dart'; // Import your RegisterAsPage
import 'package:greenloop/src/profile/Individual/presentation/view/individual_profile_page.dart';
import 'package:greenloop/src/profile/Business/presentation/view/business_profile_page.dart';
import 'package:greenloop/src/profile/recycling/presentation/view/recycling_profile_page.dart';
//import 'package:greenloop/src/profile/Recycling/presentation/view/recycling_profile_page.dart'; // Import the new page

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    context.read<LoginCubit>().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDark ? AppColors.accent : AppColors.primary;
    final Color fillColor = isDark ? const Color(0xFF232A28) : Colors.white;
    final Color labelColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color hintColor = isDark ? Colors.white : AppColors.textSecondary;
    final String fontFamily = 'Poppins';
    final String fontFamilyBold = 'Poppins-Bold';
    String? errorMessage;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            String userId = state.userId;
            String userRole = state.role;

            if (userRole == 'USER101') {
              Navigator.pushReplacementNamed(
                context,
                IndividualProfilePage.routeName,
                arguments: {'userId': userId, 'userType': userRole},
              );
            } else if (userRole == 'USER103') {
              Navigator.pushReplacementNamed(
                context,
                BusinessProfilePage.routeName,
                arguments: {'userId': userId, 'userType': userRole},
              );
            } else if (userRole == 'USER102') {
              Navigator.pushReplacementNamed(
                context,
                RecyclingProfilePage.routeName,
                arguments: {'userId': userId, 'userType': userRole},
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unknown user role: $userRole')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is LoginFailure) {
            errorMessage = state.message;
          } else {
            errorMessage = null;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF232A28) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1.2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Wrong credentials, please try again.',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: fontFamilyBold,
                                fontSize: 15.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              _styledTextField(
                context: context,
                label: "Email",
                controller: _emailController,
                borderColor: borderColor,
                fillColor: fillColor,
                labelColor: labelColor,
                hintColor: hintColor,
                fontFamily: fontFamily,
                fontFamilyBold: fontFamilyBold,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _styledTextField(
                context: context,
                label: "Password",
                controller: _passwordController,
                borderColor: borderColor,
                fillColor: fillColor,
                labelColor: labelColor,
                hintColor: hintColor,
                fontFamily: fontFamily,
                fontFamilyBold: fontFamilyBold,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state is LoginLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 17,
                  ),
                  elevation: 5,
                ),
                child: state is LoginLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterAsPage()),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    children: [
                      TextSpan(
                        text: 'Register here.',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

Widget _styledTextField({
  required BuildContext context,
  required String label,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  required Color borderColor,
  required Color fillColor,
  required Color labelColor,
  required Color hintColor,
  required String fontFamily,
  required String fontFamilyBold,
  bool obscureText = false,
  TextInputType? keyboardType,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    style: TextStyle(
      color: isDark ? Colors.white : AppColors.textPrimary,
      fontFamily: fontFamilyBold,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: labelColor,
        fontFamily: fontFamilyBold,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      hintText: label,
      hintStyle: TextStyle(
        color: hintColor,
        fontFamily: fontFamilyBold,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        letterSpacing: 1.1,
      ),
      filled: true,
      fillColor: fillColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 2.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 2.8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 2.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    onChanged: onChanged,
  );
}
}
