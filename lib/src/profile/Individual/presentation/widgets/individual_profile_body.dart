import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:greenloop/core/res/fonts.dart';



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
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        final user = state is IndividualProfileLoaded ? state.user : null;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, AppColors.backgroundTwo],
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
                  // 1. Centered Animated Profile Image
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Center(
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
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
                  // 2. Stat Cards (Points & Rewards)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _cartoonStatCard(
                          icon: Icons.star_rounded,
                          label: 'Points',
                          value: user?.points?.toString() ?? '0',
                          color: AppColors.primary,
                          iconColor: AppColors.accent,
                        ),
                        const SizedBox(width: 16),
                        _cartoonStatCard(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Rewards',
                          value: '—',
                          color: AppColors.accent,
                          iconColor: AppColors.primary,
                          isMock: true,
                        ),
                      ],
                    ),
                  ),
                  // 3. About Me Section
                  if (user?.description != null && user!.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Card(
                        color: AppColors.cardBackground,
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      user.description!,
                                      style: TextStyle(
                                        fontFamily: Fonts.fontFamily,
                                        fontSize: 15,
                                        color: AppColors.textSecondary,
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
                  // 4. Map Section
                  if (user?.location != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Card(
                        color: AppColors.cardBackground,
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
                  // 5. Animated Carousel of Recycling Tips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _RecyclingTipsCarousel(),
                  ),
                  // 6. (Optional) Pickup Waste Button (kept as is)
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/weastPage',
                            arguments: {
                              'userId': widget.userId,
                              'userType': 'Individual',
                            },
                          );
                        },
                        icon: const Icon(Icons.recycling, color: Colors.white),
                        label: const Text(
                          'Request Waste Pickup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
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
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
      image: 'https://cdn.pixabay.com/photo/2017/01/31/13/14/animal-2023924_1280.png',
      title: 'Recycle Bottles',
      description: 'Always recycle plastic bottles to keep the planet clean!',
      bgColor: AppColors.accent,
    ),
    _TipCardData(
      image: 'https://cdn.pixabay.com/photo/2017/01/31/13/14/animal-2023922_1280.png',
      title: 'Use Bins',
      description: 'Throw waste in bins, not on the ground. Help the earth!',
      bgColor: AppColors.primary,
    ),
    _TipCardData(
      image: 'https://cdn.pixabay.com/photo/2017/01/31/13/14/animal-2023923_1280.png',
      title: 'Compost',
      description: 'Compost food scraps to reduce landfill waste.',
      bgColor: AppColors.accent,
    ),
    _TipCardData(
      image: 'https://cdn.pixabay.com/photo/2017/01/31/13/14/animal-2023925_1280.png',
      title: 'Save Water',
      description: 'Turn off the tap while brushing your teeth!',
      bgColor: AppColors.primary,
    ),
    _TipCardData(
      image: 'https://cdn.pixabay.com/photo/2017/01/31/13/14/animal-2023926_1280.png',
      title: 'Plant Trees',
      description: 'Plant a tree and watch the world get greener.',
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

class _TipCardData {
  final String image;
  final String title;
  final String description;
  final Color bgColor;
  const _TipCardData({required this.image, required this.title, required this.description, required this.bgColor});
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
            child: Image.network(
              data.image,
              height: 70,
              width: 70,
              fit: BoxFit.contain,
            ),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
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
