import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/individual_profile_body.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/individual_profile_drawer.dart';

class IndividualProfilePage extends StatefulWidget {
  
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
  late IndividualProfileCubit _individualProfileCubit;

  @override
  void initState() {
    super.initState();
    _individualProfileCubit = context.read<IndividualProfileCubit>();
    _individualProfileCubit.fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        foregroundColor: isDark ? Colors.white : Colors.white,
        elevation: 2,
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
      drawer: const IndividualProfileDrawer(), 
      body: IndividualProfileBody(userId: widget.userId),
    );
  }
}