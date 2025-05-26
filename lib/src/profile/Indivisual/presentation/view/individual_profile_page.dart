import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/src/profile/Indivisual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Indivisual/presentation/widgets/individual_profile_body.dart';

class IndividualProfilePage extends StatelessWidget {
  static const String routeName = '/individualProfile';

  final String userId;
  final String userType;

  const IndividualProfilePage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<IndividualProfileCubit>()..fetchUser(userId),
      child: const Scaffold(
        body: IndividualProfileBody(),
      ),
    );
  }
}

