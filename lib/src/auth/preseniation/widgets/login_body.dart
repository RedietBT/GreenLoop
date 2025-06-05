import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/register_as_page.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    context.read<LoginCubit>().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${state.message}")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.deepSeaGreen, AppColors.caribbeanGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.mischka.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.mischka.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            fontFamily: Fonts.fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mirage,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Login to continue",
                          style: TextStyle(
                            fontFamily: Fonts.fontFamilyLight,
                            fontSize: 16,
                            color: AppColors.mischka.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 30),

                        _frostedInput(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 16),

                        _frostedInput(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state is LoginLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.turquoise.withOpacity(0.8),
                              foregroundColor: AppColors.mirage,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 8,
                            ),
                            child: state is LoginLoading
                                ? CircularProgressIndicator(color: AppColors.deepSeaGreen)
                                : const Text("Login", style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (state is LoginSuccess)
                          Text(
                            "✅ Logged in successfully",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.greenAccent,
                              fontFamily: Fonts.fontFamilyMedium,
                            ),
                          ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterAsPage()),
                          ),
                          child: Text(
                            "Don't have an account? Register here.",
                            style: TextStyle(
                              fontFamily: Fonts.fontFamily,
                              color: AppColors.mirage,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _frostedInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mischka.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: AppColors.mirage,
          fontFamily: Fonts.fontFamily,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.mirage),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.mischka.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
