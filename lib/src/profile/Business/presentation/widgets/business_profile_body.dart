import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';

class BusinessProfileBody extends StatelessWidget {
  const BusinessProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
      builder: (context, state) {
        if (state is BusinessProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BusinessProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is BusinessProfileLoaded) {
          final business = state.business;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  backgroundImage: business.avatarUrl != null && business.avatarUrl!.isNotEmpty
                      ? NetworkImage(business.avatarUrl!)
                      : null,
                  child: business.avatarUrl == null || business.avatarUrl!.isEmpty
                      ? const Icon(Icons.business, size: 70, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  business.business_name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact: ${business.contact_person_first_name} ${business.contact_person_last_name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
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
                          "Points: ${business.points ?? 'N/A'}",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Our Business",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  business.description ?? 'No description provided.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Contact Information",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Email: ${business.email}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Phone: ${business.phone_number}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Address: ${business.address ?? 'Not specified'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                     const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.work, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Role: ${business.role}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
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
