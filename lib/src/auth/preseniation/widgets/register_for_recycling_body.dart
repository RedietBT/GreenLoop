import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';

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
  final _contactController = TextEditingController();

  String password = '';
  String confirmPassword = '';


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
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'Contact Info'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
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
                                contactInfo: _contactController.text.trim(),
                                email: _emailController.text.trim(),
                                password: password,
                                userType: widget.role,
                              );
                        },
                  child: state is RegisterForRecyclingLoading
                      ? const CircularProgressIndicator()
                      : const Text("Register"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
