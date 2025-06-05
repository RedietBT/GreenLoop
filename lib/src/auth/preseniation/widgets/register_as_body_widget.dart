import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/core/commen/views/loading_view.dart';
import 'package:greenloop/core/res/colors.dart'; // Your AppColors
import 'package:greenloop/core/res/fonts.dart';  // Your Fonts

class RegisterAsPageBody extends StatelessWidget {
  const RegisterAsPageBody({super.key});

  Widget _roleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.white24,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontFamily: Fonts.fontFamilySemiBold,
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: BlocBuilder<RegisterAsCubit, RegisterAsState>(
        builder: (context, state) {
          if (state is RegisterAsLoading) {
            return const Center(child: LoadingView());
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roleButton(
                context: context,
                label: "Individual / Household",
                icon: Icons.person_outline,
                gradient: const LinearGradient(
                  colors: [AppColors.deepSeaGreen, AppColors.caribbeanGreen],
                ),
                onTap: () {
                  final role = 'Individual / Household';
                  context.read<RegisterAsCubit>().selectRole(role);
                  Navigator.pushReplacementNamed(
                    context,
                    '/registerForIndividual',
                    arguments: role,
                  );
                },
              ),
              const SizedBox(height: 24),
              _roleButton(
                context: context,
                label: "Recycling Center",
                icon: Icons.recycling,
                gradient: const LinearGradient(
                  colors: [AppColors.blueChill, AppColors.turquoise],
                ),
                onTap: () {
                  final role = 'Recycling Center';
                  context.read<RegisterAsCubit>().selectRole(role);
                  Navigator.pushReplacementNamed(
                    context,
                    '/register-recycling',
                    arguments: role,
                  );
                },
              ),
              const SizedBox(height: 24),
              _roleButton(
                context: context,
                label: "Business",
                icon: Icons.business_center,
                gradient: const LinearGradient(
                  colors: [AppColors.brightTurquoise, AppColors.caribbeanGreen],
                ),
                onTap: () {
                  final role = 'Business';
                  context.read<RegisterAsCubit>().selectRole(role);
                  Navigator.pushReplacementNamed(
                    context,
                    '/registerForIndividual',
                    arguments: role,
                  );
                },
              ),
               const SizedBox(height: 24),
              _roleButton(
                context: context,
                label: "Has an account Login",
                icon: Icons.login,
                gradient: const LinearGradient(
                  colors: [AppColors.blueChill, AppColors.turquoise],
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  );
                },
              ),

              if (state is RegisterAsRoleSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 36.0),
                  child: Text(
                    'Selected Role: ${state.role}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.deepSeaGreen,
                      fontWeight: FontWeight.w600,
                      fontFamily: Fonts.fontFamilyMedium,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
