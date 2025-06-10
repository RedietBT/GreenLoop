import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/widgets/recycling_profile_body.dart';
import 'package:greenloop/src/profile/recycling/presentation/widgets/recycling_profile_drawer.dart';


class RecyclingProfilePage extends StatefulWidget {
  static const String routeName = '/recyclingProfile';

  final String userId;
  final String userType;

  const RecyclingProfilePage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  State<RecyclingProfilePage> createState() => _RecyclingProfilePageState();
}

class _RecyclingProfilePageState extends State<RecyclingProfilePage> {
  late RecyclingProfileCubit _recyclingProfileCubit;

  @override
  void initState() {
    super.initState();
    _recyclingProfileCubit = context.read<RecyclingProfileCubit>();
    _recyclingProfileCubit.fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Profile'),
      ),
      drawer: const RecyclingProfileDrawer(),
      body: RecyclingProfileBody(userId: widget.userId),
    );
  }
} 