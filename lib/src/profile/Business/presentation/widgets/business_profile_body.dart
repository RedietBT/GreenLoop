import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';

class BusinessProfileBody extends StatefulWidget {
  final String userId; 

  const BusinessProfileBody({super.key, required this.userId});

  @override
  State<BusinessProfileBody> createState() => _BusinessProfileBodyState();
  
}

class _BusinessProfileBodyState extends State<BusinessProfileBody> {
  @override
  void initState() {
    super.initState();

    context.read<BusinessProfileCubit>().fetchUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
      builder: (context, state) {
        if (state is BusinessProfileLoading || state is BusinessProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BusinessProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is BusinessProfileLoaded) {
          final user = state.business;

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
                      ? const Icon(Icons.business, size: 70, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "${user.business_name ?? ''}",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'No email available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 30),

                //About us Section
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Us",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.description ?? 'No description available.', // Use user.description and handle null
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 20), 

                // Achievements Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Achievements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

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
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
