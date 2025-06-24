import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:greenloop/src/pickup_request/presentation/widgets/pickup_request_list.dart';
import 'package:greenloop/core/commen/widgets/global_footer.dart';
import 'package:greenloop/core/res/colors.dart';

class PickupRequestsScreen extends StatefulWidget {
  static const routeName = '/pickup-requests';
  final String recyclingCenterId;

  const PickupRequestsScreen({super.key, required this.recyclingCenterId});

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  int _currentFooterIndex = 0;

  void _onFooterTap(int index) {
    setState(() {
      _currentFooterIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/ai');
        break;
      case 2:
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
                '/login',
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
    return BlocProvider(
      create: (_) => sl<PickupRequestCubit>()
        ..getPickupRequests(widget.recyclingCenterId),
      child: Scaffold(
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
              'Pickup Requests',
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
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: BackButton(color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
        body: Column(
          children: [
            Expanded(
              child: PickupRequestList(
                recyclingCenterId: widget.recyclingCenterId,
              ),
            ),
            GlobalFooter(
              currentIndex: _currentFooterIndex,
              onTap: _onFooterTap,
            ),
          ],
        ),
      ),
    );
  }
} 