import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_body.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_drawer.dart'; 

class BusinessProfilePage extends StatefulWidget {
  
  static const String routeName = '/businessProfile';

  final String userId;
  final String userType; 

  const BusinessProfilePage({
    required this.userId,
    required this.userType,
    super.key,
  });
  
  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
  
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  late BusinessProfileCubit businessProfileCubit;

  @override
  void initState() {
    super.initState();
    businessProfileCubit = context.read<BusinessProfileCubit>();
    businessProfileCubit.fetchUserProfile(widget.userId);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile')
      ),
      drawer: const BusinessProfileDrawer(), 
      body: const BusinessProfileBody(userId: '',), 
    );
  }
}
