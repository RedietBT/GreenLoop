import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';

class RegisterForRecyclingBody extends StatefulWidget {
  final String role;
  const RegisterForRecyclingBody({
    super.key,
    required this.role
  });

  @override
  State<RegisterForRecyclingBody> createState() => _RegisterForRecyclingBodyState();
}

class _RegisterForRecyclingBodyState extends State<RegisterForRecyclingBody> {
  final _emailController = TextEditingController();
  final _centerNameController = TextEditingController();
  final _contactPersonFirstNameController = TextEditingController();
  final _contactPersonLastNameController = TextEditingController();
  final _phoneNoController = TextEditingController();

  String password = '';
  String confirmPassword = '';

  @override
  void dispose() {
    _emailController.dispose();
    _centerNameController.dispose();
    _contactPersonFirstNameController.dispose();
    _contactPersonLastNameController.dispose();
    _phoneNoController.dispose();
    super.dispose();
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
    return BlocConsumer<RegisterForRecyclingCubit, RegisterForRecyclingState>(
      listener: (context, state) {
        if (state is RegisterForRecyclingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RegisterForRecyclingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful!")),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      },
      builder: (context, state) {
        Widget content = Container(
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
                children: [
                  _styledTextField(
                    context: context,
                    label: 'Center Name',
                    controller: _centerNameController,
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 10),
                  _styledTextField(
                    context: context,
                    label: 'Contact Person First Name',
                    controller: _contactPersonFirstNameController,
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 10),
                  _styledTextField(
                    context: context,
                    label: 'Contact Person Last Name',
                    controller: _contactPersonLastNameController,
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 10),
                  _styledTextField(
                    context: context,
                    label: 'Email',
                    controller: _emailController,
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 10),
                  _styledTextField(
                    context: context,
                    label: 'Phone Number',
                    controller: _phoneNoController,
                    borderColor: borderColor,
                    fillColor: fillColor,
                    labelColor: labelColor,
                    hintColor: hintColor,
                    fontFamily: fontFamily,
                    fontFamilyBold: fontFamilyBold,
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: state is RegisterForRecyclingLoading
                        ? null
                        : () {
                            context.read<RegisterForRecyclingCubit>().registerRecycling(
                                  centerName: _centerNameController.text.trim(),
                                  contactPersonFirstName: _contactPersonFirstNameController.text.trim(),
                                  contactPersonLastName: _contactPersonLastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: password,
                                  userType: widget.role,
                                  phoneNo: _phoneNoController.text.trim().isEmpty ? '' : _phoneNoController.text.trim(),
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
                    child: state is RegisterForRecyclingLoading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
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
        return content;
      },
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
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
