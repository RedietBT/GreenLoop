import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_business_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';
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
  String phon_no = '';
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
              decoration: const InputDecoration(labelText: 'Bussiness Name'),
              onChanged: (value) => setState(() => bussinessName = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Contact Person's First Name"),
              onChanged: (value) => setState(() => ContactPersonfirstName = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Contact Person's Last Name"),
              onChanged: (value) => setState(() => ContactPersonlastName = value),
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
              decoration: const InputDecoration(labelText: 'Phone Number'),
              onChanged: (value) => setState(() => phon_no = value),
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
        );
      },
    ),
  );
}
}