import 'package:flutter/material.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_for_individual_body.dart';

class RegisterForIndividualPage extends StatelessWidget {
  static const String routeName = '/registerForIndividual';

  final String userType;

  const RegisterForIndividualPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color appBarBg = isDark ? const Color(0xFF181C1B) : Colors.transparent;
    final Color titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final String title = "Register as";
    final String role = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appBarBg,
        toolbarHeight: 120, // Increased height to push the title down
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: titleColor,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userType,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: titleColor.withOpacity(0.85),
                letterSpacing: 1.05,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: RegisterForIndividualBody(role: role),
        ),
      ),
    );
  }
}
