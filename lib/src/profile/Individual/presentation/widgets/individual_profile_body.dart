import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';


class IndividualProfileBody extends StatelessWidget {
  const IndividualProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        if (state is IndividualProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is IndividualProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is IndividualProfileLoaded) {
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "${user.first_name} ${user.last_name}",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 30),
                        const SizedBox(width: 12),
                        Text(
                          "Points: ${user.points}",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Example: Add more sections for other profile details or activities
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Me",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Achievements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Placeholder for achievements list
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No achievements yet.',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink(); // Fallback for initial or unhandled states
      },
    );
  }
}