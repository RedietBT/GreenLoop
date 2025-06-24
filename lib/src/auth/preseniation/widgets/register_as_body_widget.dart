import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/core/commen/views/loading_view.dart';
import 'package:greenloop/core/res/colors.dart';

class RegisterAsPageBody extends StatelessWidget {
  final double cardElevation;
  const RegisterAsPageBody({super.key, this.cardElevation = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color buttonTextColor = AppColors.textTertiary;
    final Color buttonBgColor = AppColors.primary;
    final Color buttonFgColor = isDark ? Colors.white : AppColors.textTertiary;
    final Color cardBg = isDark ? const Color(0xFF232A28) : Colors.white;
    final Color shadow = isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.5);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C1B) : null,
        image: isDark
            ? null
            : const DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<RegisterAsCubit, RegisterAsState>(
          builder: (context, state) {
            if (state is RegisterAsLoading) {
              return const LoadingView();
            }
            return Center(
              child: Card(
                color: cardBg,
                elevation: cardElevation,
                shadowColor: shadow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign Up As',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark? AppColors.textTertiary : AppColors.textPrimary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _registerButton(
                        context: context,
                        label: 'Individual / Household',
                        onTap: () {
                          final role = 'Individual / Household';
                          context.read<RegisterAsCubit>().selectRole(role);
                          Navigator.pushReplacementNamed(context, '/registerForIndividual', arguments: role);
                        },
                        buttonBgColor: buttonBgColor,
                        buttonFgColor: buttonFgColor,
                        buttonTextColor: buttonTextColor,
                      ),
                      const SizedBox(height: 20),
                      _registerButton(
                        context: context,
                        label: 'Recycling Center',
                        onTap: () {
                          final role = 'Recycling Center';
                          context.read<RegisterAsCubit>().selectRole(role);
                          Navigator.pushReplacementNamed(context, '/register-recycling', arguments: role);
                        },
                        buttonBgColor: buttonBgColor,
                        buttonFgColor: buttonFgColor,
                        buttonTextColor: buttonTextColor,
                      ),
                      const SizedBox(height: 20),
                      _registerButton(
                        context: context,
                        label: 'Business',
                        onTap: () {
                          final role = 'Business';
                          context.read<RegisterAsCubit>().selectRole(role);
                          Navigator.pushReplacementNamed(context, '/registerForBussiness', arguments: role);
                        },
                        buttonBgColor: buttonBgColor,
                        buttonFgColor: buttonFgColor,
                        buttonTextColor: buttonTextColor,
                      ),
                      const SizedBox(height: 20),
                      _registerButton(
                        context: context,
                        label: 'Has an account Login',
                        onTap: () {
                          final role = 'Has an account Login';
                          context.read<RegisterAsCubit>().selectRole(role);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        buttonBgColor: buttonBgColor,
                        buttonFgColor: buttonFgColor,
                        buttonTextColor: buttonTextColor,
                      ),
                      const SizedBox(height: 20),
                      if (state is RegisterAsRoleSelected)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Selected Role: ${state.role}', style: TextStyle(color: buttonTextColor)),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _registerButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required Color buttonBgColor,
    required Color buttonFgColor,
    required Color buttonTextColor,
  }) {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: buttonBgColor,
          foregroundColor: buttonFgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 7,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: buttonTextColor,
            letterSpacing: 1.1,
            shadows: [
              Shadow(
                color: buttonBgColor.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
