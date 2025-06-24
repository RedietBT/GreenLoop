import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/src/pickup_request/presentation/views/pickup_requests_screen.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/core/res/image.dart';

class RecyclingProfileBody extends StatefulWidget {
  final String userId;

  const RecyclingProfileBody({super.key, required this.userId});

  @override
  State<RecyclingProfileBody> createState() => _RecyclingProfileBodyState();
}

class _RecyclingProfileBodyState extends State<RecyclingProfileBody> {
  @override
  void initState() {
    super.initState();
    context.read<RecyclingProfileCubit>().fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecyclingProfileCubit, RecyclingProfileState>(
      builder: (context, state) {
        if (state is RecyclingProfileLoading || state is RecyclingProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecyclingProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is RecyclingProfileLoaded) {
          final user = state.user;
          // Defensive: parse location from WKT if needed
          LatLng? location = user.location;
          if (location == null && user.location is String) {
            final locationString = user.location as String?;
            if (locationString != null && locationString.isNotEmpty) {
              final regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
              final match = regex.firstMatch(locationString);
              if (match != null && match.groupCount == 2) {
                final longitude = double.tryParse(match.group(1)!);
                final latitude = double.tryParse(match.group(2)!);
                if (latitude != null && longitude != null) {
                  location = LatLng(latitude, longitude);
                }
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header with animations
                _RecyclingProfileHeader(
                  user: user,
                  delay: 0.1,
                ),
                const SizedBox(height: 24),

                // Stats Card
                _RecyclingStatsCard(
                  user: user,
                  delay: 0.2,
                ),
                const SizedBox(height: 24),

                // About Section
                _RecyclingAboutSection(
                  user: user,
                  delay: 0.3,
                ),

                // Location Map
                _RecyclingLocationSection(
                  user: user,
                  location: location,
                  delay: 0.4,
                ),

                // Carousel with slide animation
                _RecyclingCarouselSection(
                  delay: 0.5,
                ),

                // Pickup Requests Button at bottom
                _RecyclingPickupButton(
                  user: user,
                  delay: 0.6,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RecyclingProfileHeader extends StatelessWidget {
  final dynamic user;
  final double delay;
  const _RecyclingProfileHeader({required this.user, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Column(
        children: [
          Container(
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
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user?.avatar_url != null && user.avatar_url!.isNotEmpty
                  ? NetworkImage(user.avatar_url!)
                  : null,
              child: user?.avatar_url == null || user.avatar_url!.isEmpty
                  ? const Icon(Icons.recycling, size: 50, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontFamily: Fonts.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.center_name ?? 'Recycling Center',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: Fonts.fontFamilyBold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'No email available',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecyclingStatsCard extends StatelessWidget {
  final dynamic user;
  final double delay;
  const _RecyclingStatsCard({required this.user, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
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
              // Pending Requests Section
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
                        Icons.pending_actions,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '0',
                      style: const TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pending',
                      style: TextStyle(
                        fontFamily: Fonts.fontFamily,
                        fontSize: 14,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 80,
                color: Colors.transparent,
              ),
              // Completed Pickups Section
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
                        Icons.check_circle,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '0',
                      style: const TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed',
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
    );
  }
}

class _RecyclingAboutSection extends StatelessWidget {
  final dynamic user;
  final double delay;
  const _RecyclingAboutSection({required this.user, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (user?.description == null || user.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
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
                        'About Us',
                        style: TextStyle(
                          fontFamily: Fonts.fontFamilyBold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.description,
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
    );
  }
}

class _RecyclingLocationSection extends StatelessWidget {
  final dynamic user;
  final LatLng? location;
  final double delay;
  const _RecyclingLocationSection({required this.user, required this.location, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: Fonts.fontFamilyBold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (user?.address != null && user.address.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  user.address,
                  style: TextStyle(
                    fontFamily: Fonts.fontFamily,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (location != null) ...[
            const SizedBox(height: 12),
            LocationMapPreview(location: location),
          ],
        ],
      ),
    );
  }
}

class _RecyclingCarouselSection extends StatefulWidget {
  final double delay;
  const _RecyclingCarouselSection({required this.delay});

  @override
  State<_RecyclingCarouselSection> createState() => _RecyclingCarouselSectionState();
}

class _RecyclingCarouselSectionState extends State<_RecyclingCarouselSection> {
  final PageController _pageController = PageController(viewportFraction: 0.78);
  int _currentPage = 0;

  final List<_TipCardData> _tips = [
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil2,
      title: 'Recycling Center Operations',
      description: 'Professional waste processing and recycling services for your community.',
      detailedDescription: 'Our recycling center operates with state-of-the-art equipment and trained professionals to ensure efficient and environmentally responsible waste processing. We handle various types of recyclable materials including paper, cardboard, plastics, metals, and glass.\n\nOur facility follows strict environmental regulations and best practices to minimize waste and maximize recycling rates. We work closely with local communities and businesses to promote sustainable waste management practices and reduce the environmental impact of waste disposal.',
      bgColor: AppColors.primary,
      tips: [
        'Professional sorting and processing',
        'Environmental compliance',
        'Community partnerships',
        'Sustainable practices'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil3,
      title: 'Waste Collection Services',
      description: 'Reliable pickup and collection services for businesses and individuals.',
      detailedDescription: 'We provide comprehensive waste collection services tailored to meet the needs of both businesses and individuals. Our fleet of specialized vehicles and trained collection teams ensure timely and efficient pickup of recyclable materials from your location.\n\nOur collection services include scheduled pickups, on-demand collections, and special event waste management. We work with you to develop customized collection schedules that fit your needs while maximizing recycling efficiency and reducing environmental impact.',
      bgColor: AppColors.primary,
      tips: [
        'Scheduled pickups',
        'On-demand collections',
        'Special event services',
        'Customized schedules'
      ],
    ),
    _TipCardData(
      assetType: _TipAssetType.image,
      asset: MediaRes.carosil4,
      title: 'Environmental Impact',
      description: 'Making a positive difference in our community and environment.',
      detailedDescription: 'Every ton of material we recycle saves energy, reduces pollution, and conserves natural resources. Our recycling center processes thousands of tons of materials annually, significantly reducing the amount of waste sent to landfills and the associated environmental impacts.\n\nBy choosing our recycling services, you\'re contributing to a more sustainable future. We track and report our environmental impact, including energy savings, greenhouse gas reductions, and resource conservation, so you can see the positive difference your recycling efforts make.',
      bgColor: AppColors.primary,
      tips: [
        'Energy conservation',
        'Pollution reduction',
        'Resource preservation',
        'Impact tracking'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + widget.delay * 200).round()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tips_and_updates,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recycling Tips',
                  style: TextStyle(
                    fontFamily: Fonts.fontFamilyBold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
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
          ),
        ],
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

  void _showTipPopup(BuildContext context, _TipCardData tip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      tip.asset,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: tip.bgColor,
                        child: const Icon(Icons.broken_image, color: Colors.white, size: 64),
                      ),
                    ),
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
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: const TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tip.detailedDescription,
                      style: const TextStyle(
                        fontFamily: Fonts.fontFamily,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Key Points:',
                      style: TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...tip.tips.map((tipText) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tipText,
                              style: const TextStyle(
                                fontFamily: Fonts.fontFamily,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

class _RecyclingPickupButton extends StatefulWidget {
  final dynamic user;
  final double delay;

  const _RecyclingPickupButton({
    required this.user,
    required this.delay,
  });

  @override
  State<_RecyclingPickupButton> createState() => _RecyclingPickupButtonState();
}

class _RecyclingPickupButtonState extends State<_RecyclingPickupButton> with SingleTickerProviderStateMixin {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PickupRequestsScreen(
                        recyclingCenterId: widget.user.id,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt, color: Colors.white),
                    const SizedBox(width: 10),
                    const Text(
                      'View Pickup Requests',
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
          ),
        );
      },
    );
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