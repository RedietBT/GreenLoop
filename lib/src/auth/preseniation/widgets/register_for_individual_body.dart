import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
// import 'package:greenloop/src/auth/domain/entity/individual_user.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';

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

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'First Name'),
              onChanged: (value) => setState(() => firstName = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Last Name'),
              onChanged: (value) => setState(() => lastName = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => setState(() => email = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => setState(() => password = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              onChanged: (value) => setState(() => confirmPassword = value),
            ),
            const SizedBox(height: 20),
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
          ],
        );
      },
    ),
  );
}
}