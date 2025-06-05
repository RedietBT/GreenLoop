import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart'; // Import your custom colors
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart'; // Note: Check 'preseniation' vs 'presentation' typo
import 'package:greenloop/src/auth/preseniation/views/register_as_page.dart'; // Import your RegisterAsPage
import 'package:greenloop/src/profile/Individual/presentation/view/individual_profile_page.dart';
import 'package:greenloop/src/profile/Business/presentation/view/business_profile_page.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20.0), // Updated padding
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbars
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logging in...")),
            );
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide "Logging in..." snackbar
            String userId = state.userId;
            String userRole = state.role; // Get user role from the state

            // Perform role-based navigation
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
            // } else if (userRole == 'USER102') {
            //   Navigator.pushReplacementNamed(
            //     context,
            //     RecyclingProfilePage.routeName,
            //     arguments: {'userId': userId, 'userType': userRole},
            //   );
            } else {
              // Fallback for unknown roles
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unknown user role: $userRole')),
              );
            }
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any previous snackbars
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state is LoginLoading ? null : _login,
                child: state is LoginLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              const SizedBox(height: 20), // Added spacing
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterAsPage()),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Register here.',
                        style: TextStyle(color: AppColors.primary), // Using AppColors.primary
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
}
