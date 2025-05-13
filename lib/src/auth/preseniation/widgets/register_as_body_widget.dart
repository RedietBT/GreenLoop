import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/core/commen/views/loading_view.dart';

class RegisterAsPageBody extends StatelessWidget {
  const RegisterAsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BlocBuilder<RegisterAsCubit, RegisterAsState>(
        builder: (context, state) {
          if (state is RegisterAsLoading) {
            return const LoadingView(); // Show loading view
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final role = 'Individual / Household';
                  context.read<RegisterAsCubit>().selectRole(role);
                  Navigator.pushReplacementNamed(context, '/registerForIndividual', arguments: role);
                  },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text("Individual / Household"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final role = 'Recycling Center';
                  context.read<RegisterAsCubit>().selectRole(role);Navigator.pushReplacementNamed(context, '/registerForIndividual', arguments: role);
                  },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text("Recycling Center"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final role = 'Business';
                  context.read<RegisterAsCubit>().selectRole(role);Navigator.pushReplacementNamed(context, '/registerForIndividual', arguments: role);
                  },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text("Business"),
              ),
              if (state is RegisterAsRoleSelected)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Selected Role: ${state.role}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
