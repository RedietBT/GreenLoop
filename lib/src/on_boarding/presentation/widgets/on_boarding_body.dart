import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/extentions/context_extention.dart';
import 'package:greenloop/src/on_boarding/domain/entity/page_containt.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';

class OnBoardingBody extends StatefulWidget {
  const OnBoardingBody({
    required this.pageContaint,
    required this.pageIndex,
    required this.totalPages,
    super.key,
  });

  final PageContaint pageContaint;
  final int pageIndex;
  final int totalPages;

  @override
  State<OnBoardingBody> createState() => _OnBoardingBodyState();
}

class _OnBoardingBodyState extends State<OnBoardingBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_controller);
    _buttonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg1 = isDark ? const Color(0xFF181C1B) : AppColors.background;
    final Color bg2 = isDark ? const Color(0xFF232A28) : AppColors.backgroundTwo;
    final Color textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final Color textSecondary = isDark ? Colors.white70 : AppColors.textSecondary;
    final Color cardBg = isDark ? const Color(0xFF232A28) : AppColors.background;
    final Color shadow = isDark ? Colors.black.withOpacity(0.3) : AppColors.textPrimary.withOpacity(0.08);
    final Color accent = Theme.of(context).colorScheme.secondary;
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg1, bg2],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: (widget.pageIndex + 1) / widget.totalPages,
                    minHeight: 10,
                    backgroundColor: accent.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
              // Main image
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        widget.pageContaint.image,
                        height: context.height * .3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.height * .02),
              // Title
              SizedBox(height: context.height * .01),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    widget.pageContaint.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: isDark ? primary : AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.height * .01),
              // Description
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    widget.pageContaint.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? textSecondary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.height * .03),
              // Button
              ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18,
                    ),
                    elevation: 4,
                    shadowColor: primary.withOpacity(0.3),
                  ),
                  onPressed: () {
                    context.read<OnBoardingCubit>().casheFirstTimeUser();
                  },
                  child: Text(
                    "Let's Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}