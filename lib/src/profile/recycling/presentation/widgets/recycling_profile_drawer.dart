import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/profile/recycling/presentation/widgets/edit_recycling_profile_page.dart';

class RecyclingProfileDrawer extends StatelessWidget {
  const RecyclingProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    final recyclingProfileCubit = context.read<RecyclingProfileCubit>();
    return BlocConsumer<RecyclingProfileCubit, RecyclingProfileState>(
      listener: (context, state) {
        // TODO: Implement listeners for profile state changes (e.g., error, logout success)
      },
      builder: (context, state) {
        Recycling_User? userProfile;
        if (state is RecyclingProfileLoaded) {
          userProfile = state.user as Recycling_User?;
        }

        return Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userProfile?.avatar_url != null && userProfile!.avatar_url!.isNotEmpty
                          ? NetworkImage(userProfile.avatar_url!)
                          : null,
                      child: userProfile?.avatar_url == null || userProfile!.avatar_url!.isEmpty
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userProfile?.center_name ?? 'Recycling Center',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userProfile?.email ?? 'Email not available',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Edit Settings'),
                onTap: () async{
                  Navigator.pop(context);

                  final RecyclingProfileState= recyclingProfileCubit.state;

                  if(RecyclingProfileState is RecyclingProfileLoaded) {
                    final user = RecyclingProfileState.user.id;
                    
                    final bool? profileUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: recyclingProfileCubit, // Pass the SAME cubit instance
                      child: EditRecyclingProfilePage(userId: user), // Pass the userId
                    ),
                  ),
                  );
                  if (profileUpdated == true) {
                 recyclingProfileCubit.fetchUser(user); // Re-fetch the user data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile refreshed from drawer!')),
                  );
                }
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile data not yet loaded. Please wait and try again.')),
                );
              }
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 