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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins-Bold',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        foregroundColor: isDark ? Colors.white : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
      drawer: const IndividualProfileDrawer(), 
      body: IndividualProfileBody(userId: widget.userId),
    );
  }
}