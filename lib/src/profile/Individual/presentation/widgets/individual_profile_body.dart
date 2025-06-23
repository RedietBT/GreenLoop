import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/core/res/image.dart';



class IndividualProfileBody extends StatefulWidget {
  final String userId;
  const IndividualProfileBody({super.key, required this.userId});

  @override
  State<IndividualProfileBody> createState() => _IndividualProfileBodyState();
}

class _IndividualProfileBodyState extends State<IndividualProfileBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );




    _controller.forward();
    context.read<IndividualProfileCubit>().fetchUser(widget.userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        final user = state is IndividualProfileLoaded ? state.user : null;
        return _PageEntranceAnimation(
          child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
                colors: isDark ? [AppColors.backgroundDark, AppColors.backgroundTwoDark] : [AppColors.background, AppColors.backgroundTwo],
              ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<IndividualProfileCubit>().fetchUser(widget.userId);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                    // 1. Centered Animated Profile Image (bounce on tap)
                    Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 16),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _controller.reset();
                            _controller.forward();
                          },
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                              CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                            ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 54,
                                backgroundColor: AppColors.accent.withOpacity(0.2),
                                backgroundImage: user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                                child: user?.avatarUrl == null
                                    ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 2. Stat Cards (Points & Rewards) with fade/slide animation
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _EqualWidthStatCard(
                            child: AnimatedSlide(
                              offset: const Offset(-0.05, 0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutBack,
                              child: _cartoonStatCard(
                                icon: Icons.star_rounded,
                                label: 'Points',
                                value: user?.points?.toString() ?? '0',
                                color: AppColors.secondary,
                                iconColor: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _EqualWidthStatCard(
                            child: AnimatedSlide(
                              offset: const Offset(0.05, 0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutBack,
                              child: _cartoonStatCard(
                                icon: Icons.card_giftcard_rounded,
                                label: 'Rewards',
                                value: '—',
                                color: AppColors.secondary,
                                iconColor: AppColors.primary,
                                isMock: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 3. About Me Section (fade in)
                    if (user?.description != null && user!.description!.isNotEmpty)
                  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 900),
                          child: Card(
                            color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                    child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.info_outline, color: AppColors.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                        Text(
                                      'About Me',
                                      style: TextStyle(
                                            fontFamily: Fonts.fontFamilyBold,
                                            fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                            color: isDark ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          user.description!,
                                          style: TextStyle(
                                            fontFamily: Fonts.fontFamily,
                                            fontSize: 15,
                                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 4. Map Section (fade in)
                    if (user?.location != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 900),
                          child: Card(
                            color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                                child: LocationMapPreview(location: user!.location),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 5. Animated Carousel of Recycling Tips (slide in)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: AnimatedSlide(
                        offset: const Offset(0, 0.1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        child: _RecyclingTipsCarousel(),
                      ),
                    ),
                    // 6. (Optional) Pickup Waste Button (scale on tap)
                    const SizedBox(height: 16),
                    if (user != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: _AnimatedScaleButton(
                          onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/weastPage',
                                  arguments: {
                                    'userId': widget.userId,
                                    'userType': 'Individual',
                                  },
                                );
                              },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.recycling, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Request Waste Pickup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cartoonStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
    bool isMock = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 38),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: Fonts.fontFamilyBold,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (isMock)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
                child: const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                  ),
                ),
              ],
            ),
    );
  }
}

// --- Animated Carousel Widget ---
class _RecyclingTipsCarousel extends StatefulWidget {
  @override
  State<_RecyclingTipsCarousel> createState() => _RecyclingTipsCarouselState();
}

class _RecyclingTipsCarouselState extends State<_RecyclingTipsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.78);
  int _currentPage = 0;

  final List<_TipCardData> _tips = [
    _TipCardData(
      assetType: _TipAssetType.video,
      asset: MediaRes.carosil1,
      title: 'See Recycling in Action!',
      description: 'Watch how recycling makes a difference.',
      bgColor: AppColors.accent,
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil2,
      title: 'Sort Your Waste',
      description: 'Always sort your waste for better recycling.',
      bgColor: AppColors.primary,
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil3,
      title: 'Clean Before You Recycle',
      description: 'Rinse containers before putting them in the bin.',
      bgColor: AppColors.accent,
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil4,
      title: 'Use Reusable Bags',
      description: 'Reduce plastic waste by using reusable bags.',
      bgColor: AppColors.primary,
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil5,
      title: 'Compost at Home',
      description: 'Turn food scraps into garden gold!',
      bgColor: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _tips.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, i) {
          final tip = _tips[i];
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            margin: EdgeInsets.symmetric(horizontal: isActive ? 8 : 18, vertical: isActive ? 0 : 18),
            child: Transform.scale(
              scale: isActive ? 1.05 : 0.93,
              child: _CartoonTipCard(data: tip, isActive: isActive),
            ),
          );
        },
      ),
    );
  }
}

enum _TipAssetType { image, video }

class _TipCardData {
  final _TipAssetType assetType;
  final String asset;
  final String title;
  final String description;
  final Color bgColor;
  const _TipCardData({required this.assetType, required this.asset, required this.title, required this.description, required this.bgColor});
}

class _CartoonTipCard extends StatelessWidget {
  final _TipCardData data;
  final bool isActive;
  const _CartoonTipCard({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      decoration: BoxDecoration(
        color: data.bgColor.withOpacity(isActive ? 0.95 : 0.7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: data.bgColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.1 : 0.95,
            duration: const Duration(milliseconds: 500),
            child: _TipAssetWidget(data: data),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: TextStyle(
              fontFamily: Fonts.fontFamilyBold,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.fontFamily,
              fontSize: 13,
              color: Colors.white.withOpacity(0.93),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipAssetWidget extends StatelessWidget {
  final _TipCardData data;
  const _TipAssetWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.assetType == _TipAssetType.image) {
      return Image.asset(
        data.asset,
        height: 110,
        width: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image, color: Colors.red, size: 48),
        ),
      );
    } else {
      // For video, use a placeholder for now (can be replaced with a video player widget)
      return Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
      );
    }
  }
}

// Enhanced animated gradient container
class _AnimatedGradientContainer extends StatefulWidget {
  final Widget child;

  const _AnimatedGradientContainer({required this.child});

  @override
  State<_AnimatedGradientContainer> createState() => _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<_AnimatedGradientContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 2 + (_animation.value * 2),
              color: Color.lerp(
                Theme.of(context).primaryColor.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                _animation.value,
              )!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Color extension for darkening
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _AnimatedScaleButton({required this.onTap, required this.child});
  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}
class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }
  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    widget.onTap();
  }
  void _onTapCancel() {
    _controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: widget.child,
        ),
      ),
    );
  }
}

class _EqualWidthStatCard extends StatelessWidget {
  final Widget child;
  const _EqualWidthStatCard({required this.child});
  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to ensure both cards have the same width
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
        child: child,
      ),
    );
  }
}

// Page-level entrance animation
class _PageEntranceAnimation extends StatefulWidget {
  final Widget child;
  const _PageEntranceAnimation({required this.child});
  @override
  State<_PageEntranceAnimation> createState() => _PageEntranceAnimationState();
}
class _PageEntranceAnimationState extends State<_PageEntranceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(_fade);
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
