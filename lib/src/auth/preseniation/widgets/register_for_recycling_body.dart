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
           // Navigate to login page after a short delay
           Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _centerNameController,
                  decoration: const InputDecoration(labelText: 'Center Name'),
                ),
                TextField(
                  controller: _contactPersonFirstNameController,
                  decoration: const InputDecoration(labelText: 'Contact Person First Name'),
                ),
                TextField(
                  controller: _contactPersonLastNameController,
                  decoration: const InputDecoration(labelText: 'Contact Person Last Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _phoneNoController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
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
    );
  }
}
