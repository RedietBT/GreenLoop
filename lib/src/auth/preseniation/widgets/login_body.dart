import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/register_as_page.dart';
import 'package:greenloop/src/profile/Indivisual/presentation/view/individual_profile_page.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          // You might want to hide previous snackbars before showing a new one
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logging in...")),
          );
        } else if (state is LoginSuccess) {
          // Hide any current snackbar before navigating
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // Navigate to IndividualProfilePage
          Navigator.of(context).pushNamedAndRemoveUntil( // Use pushNamedAndRemoveUntil to clear login stack
            IndividualProfilePage.routeName,
            (route) => false, // Remove all previous routes
            arguments: {
              'userId': state.userId, // Assuming LoginSuccess has a userId property
              'userType': 'Individual User Page', // Pass the userType needed by the page
            },
          );
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide loading snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed: ${state.message}"),
              backgroundColor: Colors.red, // Indicate error
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state is LoginLoading ? null : _login,
                child: state is LoginLoading
                    ? const CircularProgressIndicator() // Show loading indicator
                    : const Text("Login"),
              ),
              const SizedBox(height: 20),

              // REMOVED: The Text("✅ Logged in") widget is no longer needed
              // as navigation is handled by the listener.

              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterAsPage()),
                ),
                child: const Text("Don't have an account? Register here."),
              ),
            ],
          ),
        );
      },
    );
  }
}