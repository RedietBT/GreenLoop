import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/edit_profile_page.dart'; // Import your EditProfilePage

class IndividualProfileDrawer extends StatelessWidget {
  const IndividualProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
            builder: (context, state) {
              Widget headerContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading Profile...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              );

              if (state is IndividualProfileLoaded) {
                final user = state.user;
// Get the userId here
                headerContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${user.first_name} ${user.last_name}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                );
              } else if (state is IndividualProfileError) {
                headerContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.error, size: 30, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading profile: ${state.message}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                );
              }

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: headerContent,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () async {
              Navigator.pop(context); 
               final individualProfileCubit = context.read<IndividualProfileCubit>();
              final individualProfileState = context.read<IndividualProfileCubit>().state;
              if (individualProfileState is IndividualProfileLoaded) {
                final userId = individualProfileState.user.id;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      
                     value: individualProfileCubit,
                      child: EditProfilePage(userId: userId), // Pass the userId
                    ),
                  ),
                );
              } else {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile data not yet loaded. Please try again.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout Tapped! (Implement Logout Logic)')),
              );
            },
          ),
        ],
      ),
    );
  }
}