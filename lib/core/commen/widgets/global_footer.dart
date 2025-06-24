import 'package:flutter/material.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';

class GlobalFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlobalFooter({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FooterButton(
            icon: Icons.home,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            isDark: isDark,
          ),
          _FooterButton(
            icon: Icons.smart_toy,
            label: 'AI',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            isDark: isDark,
          ),
          _FooterButton(
            icon: Icons.logout,
            label: 'Logout',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primary
                  : isDark ? Colors.white70 : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: Fonts.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? AppColors.primary
                    : isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 