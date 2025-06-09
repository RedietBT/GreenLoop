import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/src/profile/Business/presentation/widgets/edit_business_profile_page.dart'; 

class BusinessProfileDrawer extends StatelessWidget {
  const BusinessProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final businessProfileCubit = context.read<BusinessProfileCubit>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
            builder: (context, state) {
              Widget headerContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    child: const Icon(Icons.business, size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading Business Profile...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              );

              if (state is BusinessProfileLoaded) {
                final business = state.business;
                headerContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: business.avatarUrl != null && business.avatarUrl!.isNotEmpty
                          ? NetworkImage(business.avatarUrl!)
                          : null,
                      child: business.avatarUrl == null || business.avatarUrl!.isEmpty
                          ? const Icon(Icons.business, size: 30, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      business.business_name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${business.contact_person_first_name} ${business.contact_person_last_name}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              } else if (state is BusinessProfileError) {
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

              final businessProfileState = businessProfileCubit.state;
              if (businessProfileState is BusinessProfileLoaded) {
                final business = businessProfileState.business.id;
                final bool? profileUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: businessProfileCubit,
                      child: EditBusinessProfilePage(userId: business),
                    ),
                  ),
                );

                if (profileUpdated == true) {
                  businessProfileCubit.fetchUserProfile(business);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile refreshed from drawer!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile data not yet loaded. Please wait and try again.')),
                  );
                }
              }
            }  
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
