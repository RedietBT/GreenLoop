import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';

class RegisterForRecyclingBody extends StatefulWidget {
  const RegisterForRecyclingBody({super.key});

  @override
  State<RegisterForRecyclingBody> createState() => _RegisterForRecyclingBodyState();
}

class _RegisterForRecyclingBodyState extends State<RegisterForRecyclingBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _centerNameController = TextEditingController();
  final _contactController = TextEditingController();
  final String _roleId = 'USER102';

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
          Navigator.pop(context);
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
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state is RegisterForRecyclingLoading
                      ? null
                      : () {
                          final id = const Uuid().v4();
                          context.read<RegisterForRecyclingCubit>().register(
                                id: id,
                                centerName: _centerNameController.text.trim(),
                                contactInfo: _contactController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                role: _roleId,
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
