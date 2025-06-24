import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_body.dart'; 
import 'package:greenloop/src/profile/Business/presentation/widgets/business_profile_drawer.dart'; 
import 'package:greenloop/core/commen/widgets/global_footer.dart';

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
  late BusinessProfileCubit _businessProfileCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentFooterIndex = 0; // Profile page index

  @override
  void initState() {
    super.initState();
    _businessProfileCubit = context.read<BusinessProfileCubit>();
    _businessProfileCubit.fetchUserProfile(widget.userId);
  }

  void _onFooterTap(int index) {
    setState(() {
      _currentFooterIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home', // Replace with your home route
          (route) => false,
        );
        break;
      case 1: // AI
        Navigator.pushNamed(
          context,
          '/ai', // Replace with your AI route
        );
        break;
      case 2: // Logout
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
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
                '/login', // Replace with your login route
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
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
          child: Text(
            'Business Profile',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Poppins-Bold',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.settings,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
      drawer: const BusinessProfileDrawer(), 
      body: Column(
        children: [
          Expanded(
            child: BusinessProfileBody(userId: widget.userId), 
          ),
          GlobalFooter(
            currentIndex: _currentFooterIndex,
            onTap: _onFooterTap,
          ),
        ],
      ),
    );
  }
}
