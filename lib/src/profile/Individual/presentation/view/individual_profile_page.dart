// src/profile/Individual/presentation/pages/individual_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:greenloop/core/services/injection_container.dart'; // No longer needed directly here
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/individual_profile_body.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/individual_profile_drawer.dart';

class IndividualProfilePage extends StatefulWidget { // CHANGE to StatefulWidget to handle refresh logic
  static const String routeName = '/individualProfile';

  final String userId;
  final String userType;

  const IndividualProfilePage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  State<IndividualProfilePage> createState() => _IndividualProfilePageState();
}

class _IndividualProfilePageState extends State<IndividualProfilePage> {
  late IndividualProfileCubit _individualProfileCubit; // Store cubit reference

  @override
  void initState() {
    super.initState();
    // Read the existing cubit provided higher up in the tree
    _individualProfileCubit = context.read<IndividualProfileCubit>();
    // Manually trigger the fetch when the page initializes
    _individualProfileCubit.fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      drawer: const IndividualProfileDrawer(), 
      body: IndividualProfileBody(userId: widget.userId),
    );
  }
}