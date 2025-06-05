import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_body.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_drawer.dart'; 

class BusinessProfilePage extends StatelessWidget {
  static const String routeName = '/businessProfile';

  final String userId;
  final String userType; 

  const BusinessProfilePage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BusinessProfileCubit>()..fetchUserProfile(userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Business Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Tapped!')),
                );
              },
            ),
          ],
        ),
        drawer: const BusinessProfileDrawer(), 
        body: const BusinessProfileBody(), 
      ),
    );
  }
}
