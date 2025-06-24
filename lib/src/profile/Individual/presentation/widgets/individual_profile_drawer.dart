// src/profile/Individual/presentation/widgets/individual_profile_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/edit_profile_page.dart'; // Import your EditProfilePage

class IndividualProfileDrawer extends StatelessWidget {
  const IndividualProfileDrawer({super.key});

  void _logout(BuildContext context) async {
    // TODO: Replace with your actual logout logic (call cubit/repo, clear session, etc.)
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color drawerBg = isDark ? const Color(0xFF232A28) : Colors.white;
    final Color headerBg = isDark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    return Drawer(
      backgroundColor: drawerBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
            builder: (context, state) {
              Widget headerContent = AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 700),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutBack,
                      child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                  ),
                  const SizedBox(height: 8),
                    Text(
                    'Loading Profile...',
                      style: TextStyle(color: textColor, fontSize: 18),
                  ),
                ],
                ),
              );

              if (state is IndividualProfileLoaded) {
                final user = state.user;
                headerContent = AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 700),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        child: CircleAvatar(
                      radius: 30,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                        ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "${user.first_name ?? ''} ${user.last_name ?? ''}",
                        style: TextStyle(
                          color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  ),
                );
              } else if (state is IndividualProfileError) {
                headerContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.error, size: 30, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading profile: ${state.message}',
                      style: TextStyle(color: textColor, fontSize: 14),
                    ),
                  ],
                );
              }

              return DrawerHeader(
                decoration: BoxDecoration(
                  color: headerBg,
                ),
                child: headerContent,
              );
            },
          ),
          _DrawerTile(
            icon: Icons.edit,
            label: 'Edit Profile',
            onTap: () async {
              Navigator.pop(context); // Close the drawer first
              final individualProfileCubit = context.read<IndividualProfileCubit>();
              final individualProfileState = individualProfileCubit.state;
              if (individualProfileState is IndividualProfileLoaded) {
                final userId = individualProfileState.user.id;
                final bool? profileUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: individualProfileCubit,
                      child: EditProfilePage(userId: userId),
                    ),
                  ),
                );
                if (profileUpdated == true) {
                  individualProfileCubit.fetchUser(userId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile refreshed from drawer!')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile data not yet loaded. Please wait and try again.')),
                );
              }
            },
            isDark: isDark,
          ),
          _DrawerTile(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => _logout(context),
            isDark: isDark,
            isLogout: true,
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isLogout;
  const _DrawerTile({required this.icon, required this.label, required this.onTap, required this.isDark, this.isLogout = false});

  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final Color tileColor = _hovering
        ? (widget.isDark ? Colors.grey[800]! : Colors.grey[200]!)
        : Colors.transparent;
    final Color iconColor = widget.isLogout
        ? widget.isDark ? Colors.white : AppColors.textPrimary
        : (widget.isDark ? Colors.white : Colors.black87);
    final Color textColor = widget.isLogout
        ? widget.isDark ? Colors.white : AppColors.textPrimary
        : (widget.isDark ? Colors.white : Colors.black87);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        height: 56, // Fixed height for equal sizes
        child: ListTile(
          leading: Icon(widget.icon, color: iconColor, size: 24),
          title: Text(widget.label, style: TextStyle(color: textColor, fontWeight: widget.isLogout ? FontWeight.bold : FontWeight.normal)),
          tileColor: tileColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: widget.onTap,
          hoverColor: tileColor,
        ),
      ),
    );
  }
}