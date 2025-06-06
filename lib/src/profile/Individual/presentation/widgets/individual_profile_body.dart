// src/profile/Individual/presentation/widgets/individual_profile_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
// Ensure your Individual_User entity is imported if needed for direct access to its properties
// import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';

class IndividualProfileBody extends StatefulWidget {
  final String userId; // Crucially, this receives the userId from IndividualProfilePage

  const IndividualProfileBody({super.key, required this.userId});

  @override
  State<IndividualProfileBody> createState() => _IndividualProfileBodyState();
}

class _IndividualProfileBodyState extends State<IndividualProfileBody> {
  @override
  void initState() {
    super.initState();
    // This fetches the user data when IndividualProfileBody is first initialized.
    // It uses the userId passed from IndividualProfilePage.
    context.read<IndividualProfileCubit>().fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        if (state is IndividualProfileLoading || state is IndividualProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is IndividualProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is IndividualProfileLoaded) {
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Changed from 16.0 to 24.0 for more padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70, // Changed from 60 to 70 for larger avatar
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 70, color: Colors.white) // Changed icon size
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  // Handle potential nulls for first_name and last_name
                  "${user.first_name ?? ''} ${user.last_name ?? ''}",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), // Added spacing for email
                Text(
                  user.email ?? 'No email available', // Handle null email
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Spacing before the points card

                // Points Card
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
                          // Handle potential null for points
                          "Points: ${user.points ?? 0}",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Spacing before About Me

                // About Me Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Me",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.description ?? 'No description available.', // Use user.description and handle null
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 20), // Spacing before Achievements

                // Achievements Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Achievements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Placeholder for achievements list (you can replace this with a dynamic list later)
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
                // Add more profile details if needed
              ],
            ),
          );
        }
        // Fallback for states like IndividualProfileInitial (which might already be handled above)
        // or any other unhandled states. SizedBox.shrink() is a safe default.
        return const SizedBox.shrink();
      },
    );
  }
}