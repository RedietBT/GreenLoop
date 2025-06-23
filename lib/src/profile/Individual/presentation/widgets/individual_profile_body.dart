import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/core/res/image.dart';
import 'package:greenloop/src/profile/Individual/presentation/widgets/individual_profile_drawer.dart';



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
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: IndividualProfileDrawer(),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<IndividualProfileCubit>().fetchUser(widget.userId);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Profile Picture and Welcome Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _ProfileWelcomeSection(
                      user: user,
                      delay: 0.0,
                    ),
                  ),

                  // Combined Points & Rewards Card
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _CombinedStatsCard(
                      user: user,
                      delay: 0.1,
                    ),
                  ),

                  // Waste Submissions & Trophy Section
                  _AnimatedWasteSubmissionsSection(
                    user: user,
                    delay: 0.2,
                  ),

                  // 3. About Section with slide animation
                  _AnimatedAboutSection(
                    user: user,
                    delay: 0.3,
                  ),

                  // 4. Location Map with slide animation
                  _AnimatedLocationSection(
                    user: user,
                    delay: 0.4,
                  ),

                  // 5. Carousel with slide animation
                  _AnimatedCarouselSection(
                    delay: 0.5,
                  ),

                  // 6. Pickup Waste Button with scale animation
                  if (user != null)
                    _AnimatedPickupButton(
                      userId: widget.userId,
                      delay: 0.6,
                    ),

                  // Bottom padding for better scrolling
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
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
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil2,
      title: 'Global Waste Crisis',
      description: '2.01 billion tons of waste generated annually worldwide. Your small actions can make a huge difference!',
      detailedDescription: 'The world generates over 2 billion tons of municipal solid waste annually, with only 13.5% being recycled. This massive amount of waste contributes significantly to environmental pollution, climate change, and resource depletion. Landfills are overflowing, oceans are filling with plastic, and natural habitats are being destroyed by waste accumulation.\n\nBy 2050, global waste is expected to grow to 3.4 billion tons if current trends continue. Every piece of waste you properly sort and recycle helps reduce this crisis. Your individual actions, when multiplied by millions of people, can create a significant positive impact on our planet\'s health and future sustainability.',
      bgColor: AppColors.primary,
      tips: [
        'Separate organic waste from recyclables',
        'Use composting for food scraps',
        'Support local recycling programs',
        'Reduce single-use plastics'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil3,
      title: 'Sort Your Waste',
      description: 'Always sort your waste for better recycling.',
      detailedDescription: 'Proper waste sorting is the foundation of effective recycling. When waste is correctly separated, it can be processed more efficiently and with higher quality results. Different materials require different recycling processes, and contamination can render entire batches unusable, leading to more waste being sent to landfills.\n\nBy taking the time to sort your waste properly, you ensure that valuable materials can be recovered and reused. This not only conserves natural resources but also reduces the energy and emissions associated with producing new materials from scratch. Your sorting efforts directly contribute to a more sustainable and circular economy.',
      bgColor: AppColors.primary,
      tips: [
        'Paper and cardboard in one bin',
        'Plastics, metals, and glass separately',
        'Organic waste in compost bin',
        'Hazardous waste to special facilities'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil4,
      title: 'Clean Before You Recycle',
      description: 'Rinse containers before putting them in the bin.',
      detailedDescription: 'Clean recyclables are essential for successful recycling. Food residue, grease, and other contaminants can make materials unrecyclable or reduce their quality significantly. When dirty items are mixed with clean recyclables, they can contaminate entire batches, causing them to be rejected by recycling facilities.\n\nA quick rinse can make the difference between waste and valuable recycled material. Clean materials are easier to process, require less energy to recycle, and produce higher quality recycled products. This simple step ensures that your recycling efforts are effective and that materials can be properly transformed into new products.',
      bgColor: AppColors.primary,
      tips: [
        'Rinse food containers thoroughly',
        'Remove labels when possible',
        'Dry items before recycling',
        'Check local guidelines for specific requirements'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil5,
      title: 'Use Reusable Bags',
      description: 'Reduce plastic waste by using reusable bags.',
      detailedDescription: 'Single-use plastic bags are one of the most common forms of plastic pollution worldwide. They take hundreds of years to decompose and often end up in oceans, harming marine life and contributing to the global plastic crisis. These bags are used for an average of just 12 minutes before being discarded, yet they persist in the environment for centuries.\n\nSwitching to reusable bags is a simple yet powerful way to reduce your environmental footprint. Reusable bags can be used hundreds of times, significantly reducing the demand for single-use plastics. This small change in daily habits can prevent thousands of plastic bags from entering landfills and oceans over a lifetime.',
      bgColor: AppColors.primary,
      tips: [
        'Keep reusable bags in your car',
        'Choose durable, washable materials',
        'Use different sizes for different purposes',
        'Remember to bring them shopping'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil2,
      title: 'Compost at Home',
      description: 'Turn food scraps into garden gold!',
      detailedDescription: 'Home composting reduces waste sent to landfills and creates nutrient-rich soil for your garden. Organic waste in landfills produces methane, a potent greenhouse gas that contributes significantly to climate change. When food scraps decompose in oxygen-deprived landfill conditions, they release methane, which is 25 times more effective at trapping heat than carbon dioxide.\n\nComposting at home is a natural process that returns nutrients to the soil and reduces your carbon footprint. The resulting compost improves soil structure, retains moisture, and provides essential nutrients for plants. This creates a sustainable cycle where your food waste becomes a valuable resource for growing more food.',
      bgColor: AppColors.primary,
      tips: [
        'Use fruit and vegetable scraps',
        'Add coffee grounds and eggshells',
        'Avoid meat and dairy products',
        'Maintain proper moisture and aeration'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _tips.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, i) {
          final tip = _tips[i];
          final isActive = i == _currentPage;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: isActive ? 8 : 18, vertical: isActive ? 0 : 18),
            child: _CartoonTipCard(data: tip, isActive: isActive),
          );
        },
      ),
    );
  }
}

enum _TipAssetType { image }

class _TipCardData {
  final _TipAssetType assetType;
  final String asset;
  final String title;
  final String description;
  final String detailedDescription;
  final Color bgColor;
  final List<String> tips;
  
  const _TipCardData({
    required this.assetType, 
    required this.asset, 
    required this.title, 
    required this.description, 
    required this.detailedDescription,
    required this.bgColor,
    required this.tips,
  });
}

class _CartoonTipCard extends StatelessWidget {
  final _TipCardData data;
  final bool isActive;
  const _CartoonTipCard({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTipPopup(context, data),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  data.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: data.bgColor,
                    child: const Icon(Icons.broken_image, color: Colors.white, size: 48),
                  ),
                ),
              ),
              // Gradient Overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedScale(
                        scale: isActive ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontFamily: Fonts.fontFamilyBold,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.description,
                        style: const TextStyle(
                          fontFamily: Fonts.fontFamily,
                          fontSize: 14,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Tap to learn more',
                          style: TextStyle(
                            fontFamily: Fonts.fontFamily,
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipPopup(BuildContext context, _TipCardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      data.asset,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: data.bgColor,
                        child: const Icon(Icons.broken_image, color: Colors.white, size: 64),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontFamily: Fonts.fontFamilyBold,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // First paragraph
                      Text(
                        data.detailedDescription.split('\n\n').first,
                        style: TextStyle(
                          fontFamily: Fonts.fontFamily,
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Second paragraph (if available)
                      if (data.detailedDescription.split('\n\n').length > 1)
                        Text(
                          data.detailedDescription.split('\n\n').skip(1).join('\n\n'),
                          style: TextStyle(
                            fontFamily: Fonts.fontFamily,
                            fontSize: 16,
                            height: 1.6,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Got it!',
                            style: TextStyle(
                              fontFamily: Fonts.fontFamilyBold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ignore: unused_element
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

// ignore: unused_element
class _EqualWidthStatCard extends StatelessWidget {
  final Widget child;
  const _EqualWidthStatCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 180,
          minHeight: 120,
          maxHeight: 140,
        ),
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

// Animated About Section Widget
class _AnimatedAboutSection extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _AnimatedAboutSection({
    required this.user,
    required this.delay,
  });

  @override
  State<_AnimatedAboutSection> createState() => _AnimatedAboutSectionState();
}

class _AnimatedAboutSectionState extends State<_AnimatedAboutSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.user?.description == null || widget.user.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 28,
                        ),
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
                              widget.user.description,
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
        );
      },
    );
  }
}

// Animated Location Section Widget
class _AnimatedLocationSection extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _AnimatedLocationSection({
    required this.user,
    required this.delay,
  });

  @override
  State<_AnimatedLocationSection> createState() => _AnimatedLocationSectionState();
}

class _AnimatedLocationSectionState extends State<_AnimatedLocationSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.user?.location == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'My Location',
                              style: TextStyle(
                                fontFamily: Fonts.fontFamilyBold,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LocationMapPreview(location: widget.user.location),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Animated Carousel Section Widget
class _AnimatedCarouselSection extends StatefulWidget {
  final double delay;

  const _AnimatedCarouselSection({
    required this.delay,
  });

  @override
  State<_AnimatedCarouselSection> createState() => _AnimatedCarouselSectionState();
}

class _AnimatedCarouselSectionState extends State<_AnimatedCarouselSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _RecyclingTipsCarousel(),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedWasteSubmissionsSection extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _AnimatedWasteSubmissionsSection({
    required this.user,
    required this.delay,
  });

  @override
  State<_AnimatedWasteSubmissionsSection> createState() => _AnimatedWasteSubmissionsSectionState();
}

class _AnimatedWasteSubmissionsSectionState extends State<_AnimatedWasteSubmissionsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _WasteSubmissionsSection(user: widget.user),
            ),
          ),
        );
      },
    );
  }
}

class _WasteSubmissionsSection extends StatelessWidget {
  final dynamic user;
  const _WasteSubmissionsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final submissionCount = user?.no_of_weaste ?? 0;
    final trophyLevel = (submissionCount / 3).floor();
    
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.accent.withOpacity(0.08),
                ]
              : [
                  AppColors.primary.withOpacity(0.06),
                  AppColors.accent.withOpacity(0.04),
                ],
          ),
        ),
        child: Row(
          children: [
            // Waste Submissions Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.recycling,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$submissionCount',
                              style: const TextStyle(
                                fontFamily: Fonts.fontFamilyBold,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Waste Submissions',
                              style: TextStyle(
                                fontFamily: Fonts.fontFamily,
                                fontSize: 16,
                                color: isDark ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress to next trophy
                  if (submissionCount < 3)
                    Text(
                      '${3 - (submissionCount % 3)} more to next trophy!',
                      style: TextStyle(
                        fontFamily: Fonts.fontFamily,
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    )
                  else if (submissionCount % 3 == 0)
                    Text(
                      'Trophy earned! 🏆',
                      style: TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '${3 - (submissionCount % 3)} more to next trophy!',
                      style: TextStyle(
                        fontFamily: Fonts.fontFamily,
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Trophy Section
            _AnimatedTrophy(
              trophyLevel: trophyLevel,
              submissionCount: submissionCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTrophy extends StatefulWidget {
  final int trophyLevel;
  final int submissionCount;
  
  const _AnimatedTrophy({
    required this.trophyLevel,
    required this.submissionCount,
  });

  @override
  State<_AnimatedTrophy> createState() => _AnimatedTrophyState();
}

class _AnimatedTrophyState extends State<_AnimatedTrophy> with TickerProviderStateMixin {
  late AnimationController _trophyController;
  late AnimationController _breakController;
  late Animation<double> _trophyScale;
  late Animation<double> _trophySlide;
  late Animation<double> _breakAnimation;
  
  int _previousTrophyLevel = 0;
  bool _shouldBreak = false;

  @override
  void initState() {
    super.initState();
    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _breakController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _trophyScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trophyController,
      curve: Curves.elasticOut,
    ));
    
    _trophySlide = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _trophyController,
      curve: Curves.easeInBack,
    ));
    
    _breakAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breakController,
      curve: Curves.easeIn,
    ));
    
    _checkTrophyChange();
  }

  @override
  void didUpdateWidget(_AnimatedTrophy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trophyLevel != widget.trophyLevel) {
      _previousTrophyLevel = oldWidget.trophyLevel;
      _shouldBreak = true;
      _breakController.forward().then((_) {
        _trophyController.forward();
      });
    }
  }

  void _checkTrophyChange() {
    if (widget.trophyLevel > 0) {
      _trophyController.forward();
    }
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Previous trophy breaking animation
        if (_shouldBreak)
          AnimatedBuilder(
            animation: _breakAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - _breakAnimation.value,
                child: Transform.rotate(
                  angle: _breakAnimation.value * 0.5,
                  child: Opacity(
                    opacity: 1.0 - _breakAnimation.value,
                    child: _getTrophyIcon(_previousTrophyLevel),
                  ),
                ),
              );
            },
          ),
        
        // Current trophy
        AnimatedBuilder(
          animation: _trophyController,
          builder: (context, child) {
            return Transform.scale(
              scale: _trophyScale.value,
              child: Transform.translate(
                offset: Offset(0, _trophySlide.value * 50),
                child: _getTrophyIcon(widget.trophyLevel),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _getTrophyIcon(int level) {
    IconData iconData;
    Color color;
    double size;
    String trophyName;
    
    switch (level) {
      case 0:
        iconData = Icons.emoji_events_outlined;
        color = Colors.grey;
        size = 60;
        trophyName = 'No Trophy';
        break;
      case 1:
        iconData = Icons.emoji_events;
        color = const Color(0xFFCD7F32); // Bronze
        size = 60;
        trophyName = 'Bronze';
        break;
      case 2:
        iconData = Icons.workspace_premium;
        color = const Color(0xFFC0C0C0); // Silver
        size = 65;
        trophyName = 'Silver';
        break;
      case 3:
        iconData = Icons.diamond;
        color = const Color(0xFFFFD700); // Gold
        size = 70;
        trophyName = 'Gold';
        break;
      case 4:
        iconData = Icons.star;
        color = const Color(0xFFE5E4E2); // Platinum
        size = 75;
        trophyName = 'Platinum';
        break;
      case 5:
        iconData = Icons.workspace_premium;
        color = const Color(0xFFB9F2FF); // Diamond
        size = 80;
        trophyName = 'Diamond';
        break;
      default:
        iconData = Icons.auto_awesome;
        color = const Color(0xFF9B59B6); // Purple
        size = 85;
        trophyName = 'Legendary';
        break;
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            iconData,
            color: color,
            size: size,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          trophyName,
          style: TextStyle(
            fontFamily: Fonts.fontFamilyBold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AnimatedPickupButton extends StatefulWidget {
  final String userId;
  final double delay;

  const _AnimatedPickupButton({
    required this.userId,
    required this.delay,
  });

  @override
  State<_AnimatedPickupButton> createState() => _AnimatedPickupButtonState();
}

class _AnimatedPickupButtonState extends State<_AnimatedPickupButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.recycling,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Request Waste Pickup',
                        style: TextStyle(
                          fontFamily: Fonts.fontFamilyBold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Combined Stats Card Widget
class _CombinedStatsCard extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _CombinedStatsCard({
    required this.user,
    required this.delay,
  });

  @override
  State<_CombinedStatsCard> createState() => _CombinedStatsCardState();
}

class _CombinedStatsCardState extends State<_CombinedStatsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Card(
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.accent.withOpacity(0.1),
                        ]
                      : [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.accent.withOpacity(0.05),
                        ],
                  ),
                ),
                child: Row(
                  children: [
                    // Points Section
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.stars,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.user?.points ?? 0}',
                            style: const TextStyle(
                              fontFamily: Fonts.fontFamilyBold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Points',
                            style: TextStyle(
                              fontFamily: Fonts.fontFamily,
                              fontSize: 14,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Invisible Divider Line
                    Container(
                      width: 1,
                      height: 80,
                      color: Colors.transparent,
                    ),
                    
                    // Rewards Section
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.card_giftcard,
                              color: AppColors.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '0',
                            style: TextStyle(
                              fontFamily: Fonts.fontFamilyBold,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rewards',
                            style: TextStyle(
                              fontFamily: Fonts.fontFamily,
                              fontSize: 14,
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
        );
      },
    );
  }
}

// Profile Welcome Section Widget
class _ProfileWelcomeSection extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _ProfileWelcomeSection({
    required this.user,
    required this.delay,
  });

  @override
  State<_ProfileWelcomeSection> createState() => _ProfileWelcomeSectionState();
}

class _ProfileWelcomeSectionState extends State<_ProfileWelcomeSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    Future.delayed(Duration(milliseconds: (widget.delay * 200).round()), () {
      if (mounted) _controller.forward();
    });
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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Profile Picture
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: widget.user?.avatarUrl != null
                          ? NetworkImage(widget.user!.avatarUrl!)
                          : null,
                      child: widget.user?.avatarUrl == null
                          ? const Icon(Icons.person, size: 70, color: AppColors.primary)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Welcome Message
                Text(
                  'Welcome to GreenLoop',
                  style: TextStyle(
                    fontFamily: Fonts.fontFamilyBold,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (widget.user != null)
                  Text(
                    '${widget.user.first_name ?? ''} ${widget.user.last_name ?? ''}',
                    style: TextStyle(
                      fontFamily: Fonts.fontFamily,
                      fontSize: 18,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
