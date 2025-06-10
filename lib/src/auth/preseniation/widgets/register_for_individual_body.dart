import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';

class RegisterForIndividualBody extends StatefulWidget {
  final String role;   
  const RegisterForIndividualBody({super.key, required this.role});
  

  @override
  State<RegisterForIndividualBody> createState() => _RegisterForIndividualBodyState();
}

class _RegisterForIndividualBodyState extends State<RegisterForIndividualBody> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String? error;

  @override
Widget build(BuildContext context) {
  return BlocListener<RegisterForIndividualCubit, RegisterForIndividualState>(
    listener: (context, state) {
      if (state is RegisterForIndividualSuccess) {
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
    child: BlocBuilder<RegisterForIndividualCubit, RegisterForIndividualState>(
      builder: (context, state) {
        if (state is RegisterForIndividualLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'), // Ensure you have this image
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => firstName = value),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => lastName = value),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => email = value),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  onChanged: (value) => setState(() => password = value),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  onChanged: (value) => setState(() => confirmPassword = value),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() => error = null);

                    if (password != confirmPassword) {
                      setState(() => error = "Passwords do not match.");
                      return;
                    }

                    context.read<RegisterForIndividualCubit>().registerIndividual(
                          email: email,
                          password: password,
                          firstName: firstName,
                          lastName: lastName,
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
                if (state is RegisterForIndividualFailure)
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
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Login here.',
                            style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}