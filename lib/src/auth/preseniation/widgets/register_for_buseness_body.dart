import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_business_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_business_state.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';

class RegisterForBussinessPageBody extends StatefulWidget {
  final String role;   
  const RegisterForBussinessPageBody({super.key, required this.role});
  

  @override
  State<RegisterForBussinessPageBody> createState() => _RegisterForIndividualBodyState();
}

class _RegisterForIndividualBodyState extends State<RegisterForBussinessPageBody> {
  String bussinessName = '';
  String ContactPersonfirstName = '';
  String ContactPersonlastName = '';
  String email = '';
  String phon_no = '';
  String password = '';
  String confirmPassword = '';
  String? error;

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final Color borderColor = isDark ? AppColors.accent : AppColors.primary;
  final Color fillColor = isDark ? const Color(0xFF232A28) : Colors.white;
  final Color labelColor = isDark ? Colors.white : AppColors.textPrimary;
  final Color hintColor = isDark ? Colors.white : AppColors.textSecondary;
  final String fontFamily = 'Poppins';
  final String fontFamilyBold = 'Poppins-Bold';
  return BlocListener<RegisterForBusinessCubit, RegisterForBusinessState>(
    listener: (context, state) {
      if (state is RegisterForBusinessSuccess) {
        // Show a success message and wait for email verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful. Please verify your email."),
          ),
        );

        // Navigate to login page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      }
    },
    child: BlocBuilder<RegisterForBusinessCubit, RegisterForBusinessState>(
      builder: (context, state) {
        if (state is RegisterForBusinessLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181C1B) : null,
            image: isDark
                ? null
                : const DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _styledTextField(
                    context: context,
                    label: 'Business Name',
                    onChanged: (value) => setState(() => bussinessName = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: "Contact Person's First Name",
                    onChanged: (value) => setState(() => ContactPersonfirstName = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: "Contact Person's Last Name",
                    onChanged: (value) => setState(() => ContactPersonlastName = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: 'Email',
                    onChanged: (value) => setState(() => email = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: 'Phone Number (e.g., +251911121314)',
                    onChanged: (value) => setState(() => phon_no = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: 'Password',
                    onChanged: (value) => setState(() => password = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _styledTextField(
                    context: context,
                    label: 'Confirm Password',
                    onChanged: (value) => setState(() => confirmPassword = value),
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => error = null);

                      if (password != confirmPassword) {
                        setState(() => error = "Passwords do not match.");
                        return;
                      }

                      context.read<RegisterForBusinessCubit>().registerBussiness(
                            email: email,
                            password: password,
                            contactPersonFirstName: ContactPersonfirstName,
                            contactPersonLastName: ContactPersonlastName,
                            businessName: bussinessName,
                            phoneNo: phon_no,
                            userType: widget.role,
                          );
                    },
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
                    child: const Text("Register"),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (state is RegisterForBusinessFailure)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        state.message ?? 'An unknown error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'have an account? ',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        children: [
                          TextSpan(
                            text: 'Login here.',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _styledTextField({
  required BuildContext context,
  required String label,
  required ValueChanged<String> onChanged,
  required Color borderColor,
  required Color fillColor,
  required Color labelColor,
  required Color hintColor,
  required String fontFamily,
  required String fontFamilyBold,
  bool obscureText = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextField(
    obscureText: obscureText,
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