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
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      },
      builder: (context, state) {
        Widget content = Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _centerNameController,
                    decoration: InputDecoration(
                      labelText: 'Center Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactPersonFirstNameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Person First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactPersonLastNameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Person Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneNoController,
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
          ),
        );
        return content;
      },
    );
  }
}
