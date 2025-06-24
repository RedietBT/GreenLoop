import 'package:flutter/material.dart';
import 'package:greenloop/src/waste/presentation/wedigit/weast_body.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/commen/widgets/global_footer.dart';

class WeastPage extends StatefulWidget{

  static const String routeName = '/weastPage';

  final String userId;
  final String userType;

  const WeastPage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  State<WeastPage> createState() => _WeastPageState();
}

class _WeastPageState extends State<WeastPage>{
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
    return Scaffold(
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
            'Request Waste Pickup',
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
            child: WeastBody(userId: widget.userId),
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