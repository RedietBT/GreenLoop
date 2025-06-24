import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'dart:typed_data';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';

class BusinessProfileBody extends StatefulWidget {
  final String userId; 

  const BusinessProfileBody({super.key, required this.userId});

  @override
  State<BusinessProfileBody> createState() => _BusinessProfileBodyState();
  
}

class _BusinessProfileBodyState extends State<BusinessProfileBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    context.read<BusinessProfileCubit>().fetchUserProfile(widget.userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
      builder: (context, state) {
        if (state is BusinessProfileLoading || state is BusinessProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BusinessProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is BusinessProfileLoaded) {
          final user = state.business;
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

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<BusinessProfileCubit>().fetchUserProfile(widget.userId);
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Profile Picture and Welcome Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _BusinessProfileHeader(
                        business: user,
                        delay: 0.0,
                      ),
                    ),
                    // Combined Points & Waste Card
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _BusinessStatsCard(
                        business: user,
                        delay: 0.1,
                      ),
                    ),
                    // Waste Submissions & Trophy Section
                    _BusinessWasteTrophySection(
                      business: user,
                      delay: 0.2,
                    ),
                    // About Section
                    _BusinessAboutSection(
                      business: user,
                      delay: 0.3,
                    ),
                    // Location Map
                    _BusinessLocationSection(
                      business: user,
                      delay: 0.4,
                    ),
                    // Carousel with slide animation
                    _BusinessCarouselSection(
                      delay: 0.5,
                    ),
                    // Pickup Waste Button
                    _BusinessPickupButton(
                      userId: widget.userId,
                      delay: 0.6,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _BusinessProfileHeader extends StatelessWidget {
  final dynamic business;
  final double delay;
  const _BusinessProfileHeader({required this.business, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Column(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: business?.avatarUrl != null && business.avatarUrl.isNotEmpty
                  ? NetworkImage(business.avatarUrl)
                  : null,
              child: business?.avatarUrl == null || business.avatarUrl.isEmpty
                  ? const Icon(Icons.business, size: 50, color: Colors.grey)
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
            business?.business_name ?? '',
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
            business?.email ?? '',
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

class _BusinessStatsCard extends StatelessWidget {
  final dynamic business;
  final double delay;
  const _BusinessStatsCard({required this.business, required this.delay});

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
                      '${business?.points ?? 0}',
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
              // Divider
              Container(
                width: 1,
                height: 80,
                color: Colors.transparent,
              ),
              // Waste Submissions Section
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
                        Icons.recycling,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${business?.no_of_weaste ?? 0}',
                      style: const TextStyle(
                        fontFamily: Fonts.fontFamilyBold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waste Submissions',
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

class _BusinessWasteTrophySection extends StatelessWidget {
  final dynamic business;
  final double delay;
  const _BusinessWasteTrophySection({required this.business, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final submissionCount = business?.no_of_weaste ?? 0;
    final trophyLevel = (submissionCount / 3).floor();
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Card(
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
              _BusinessTrophy(
                trophyLevel: trophyLevel,
                submissionCount: submissionCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessTrophy extends StatelessWidget {
  final int trophyLevel;
  final int submissionCount;
  const _BusinessTrophy({required this.trophyLevel, required this.submissionCount});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;
    double size;
    String trophyName;
    switch (trophyLevel) {
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

class _BusinessAboutSection extends StatelessWidget {
  final dynamic business;
  final double delay;
  const _BusinessAboutSection({required this.business, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Us",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                business?.description ?? 'No description available.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                "Address",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                business?.address ?? 'No Address available.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessLocationSection extends StatelessWidget {
  final dynamic business;
  final double delay;
  const _BusinessLocationSection({required this.business, required this.delay});

  @override
  Widget build(BuildContext context) {
    LatLng? location = business?.location;
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LocationMapPreview(location: location),
        ),
      ),
    );
  }
}

class _BusinessCarouselSection extends StatelessWidget {
  final double delay;
  const _BusinessCarouselSection({required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recycling Tips',
                style: TextStyle(
                  fontFamily: Fonts.fontFamilyBold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _BusinessRecyclingTipsCarousel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessRecyclingTipsCarousel extends StatefulWidget {
  @override
  State<_BusinessRecyclingTipsCarousel> createState() => _BusinessRecyclingTipsCarouselState();
}

class _BusinessRecyclingTipsCarouselState extends State<_BusinessRecyclingTipsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.78);
  int _currentPage = 0;

  final List<_BusinessTipCardData> _tips = [
    _BusinessTipCardData(
      assetType: _BusinessTipAssetType.image,
      asset: 'assets/images/carosil2.png',
      title: 'Global Waste Crisis',
      description: '2.01 billion tons of waste generated annually worldwide. Your business can make a huge difference!',
      detailedDescription: 'The world generates over 2 billion tons of municipal solid waste annually, with only 13.5% being recycled. This massive amount of waste contributes significantly to environmental pollution, climate change, and resource depletion. Landfills are overflowing, oceans are filling with plastic, and natural habitats are being destroyed by waste accumulation.\n\nBy 2050, global waste is expected to grow to 3.4 billion tons if current trends continue. Every piece of waste your business properly sorts and recycles helps reduce this crisis. Your business actions, when multiplied by thousands of companies, can create a significant positive impact on our planet\'s health and future sustainability.',
      bgColor: AppColors.primary,
      tips: [
        'Implement waste sorting systems',
        'Train employees on recycling',
        'Partner with local recycling centers',
        'Reduce single-use plastics in operations'
      ],
    ),
    _BusinessTipCardData(
      assetType: _BusinessTipAssetType.image,
      asset: 'assets/images/carosil3.png',
      title: 'Business Waste Management',
      description: 'Implement proper waste sorting for better recycling efficiency.',
      detailedDescription: 'Proper waste sorting is the foundation of effective business recycling. When waste is correctly separated, it can be processed more efficiently and with higher quality results. Different materials require different recycling processes, and contamination can render entire batches unusable, leading to more waste being sent to landfills.\n\nBy taking the time to sort your business waste properly, you ensure that valuable materials can be recovered and reused. This not only conserves natural resources but also reduces the energy and emissions associated with producing new materials from scratch. Your business sorting efforts directly contribute to a more sustainable and circular economy.',
      bgColor: AppColors.primary,
      tips: [
        'Separate paper and cardboard',
        'Sort plastics, metals, and glass',
        'Handle organic waste properly',
        'Dispose of hazardous waste safely'
      ],
    ),
    _BusinessTipCardData(
      assetType: _BusinessTipAssetType.image,
      asset: 'assets/images/carosil4.png',
      title: 'Clean Before Recycling',
      description: 'Ensure containers are clean before recycling to maintain quality.',
      detailedDescription: 'Clean recyclables are essential for successful business recycling. Food residue, grease, and other contaminants can make materials unrecyclable or reduce their quality significantly. When dirty items are mixed with clean recyclables, they can contaminate entire batches, causing them to be rejected by recycling facilities.\n\nA quick rinse can make the difference between waste and valuable recycled material. Clean materials are easier to process, require less energy to recycle, and produce higher quality recycled products. This simple step ensures that your business recycling efforts are effective and that materials can be properly transformed into new products.',
      bgColor: AppColors.primary,
      tips: [
        'Rinse food containers thoroughly',
        'Remove labels when possible',
        'Dry items before recycling',
        'Follow local recycling guidelines'
      ],
    ),
    _BusinessTipCardData(
      assetType: _BusinessTipAssetType.image,
      asset: 'assets/images/carosil5.png',
      title: 'Sustainable Business Practices',
      description: 'Adopt sustainable practices to reduce environmental impact.',
      detailedDescription: 'Sustainable business practices are crucial for reducing environmental impact and creating a positive corporate image. By implementing eco-friendly policies, businesses can significantly reduce their carbon footprint while often saving money in the long run. Sustainable practices include reducing energy consumption, minimizing waste, and choosing environmentally friendly suppliers.\n\nConsumers are increasingly choosing businesses that demonstrate environmental responsibility. By adopting sustainable practices, your business can attract environmentally conscious customers, improve employee satisfaction, and contribute to a healthier planet. These practices also often lead to operational efficiencies and cost savings.',
      bgColor: AppColors.primary,
      tips: [
        'Use energy-efficient equipment',
        'Implement paperless systems',
        'Choose sustainable suppliers',
        'Educate employees on sustainability'
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return GestureDetector(
                onTap: () => _showTipDetails(context, tip),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: Image.asset(
                            tip.asset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: tip.bgColor,
                              child: const Icon(Icons.broken_image, color: Colors.white, size: 64),
                            ),
                          ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.fontFamilyBold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tip.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: Fonts.fontFamily,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _tips.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index 
                    ? AppColors.primary 
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTipDetails(BuildContext context, _BusinessTipCardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
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
    );
  }
}

enum _BusinessTipAssetType { image}

class _BusinessTipCardData {
  final _BusinessTipAssetType assetType;
  final String asset;
  final String title;
  final String description;
  final String detailedDescription;
  final Color bgColor;
  final List<String> tips;

  const _BusinessTipCardData({
    required this.assetType,
    required this.asset,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.bgColor,
    required this.tips,
  });
}

class _BusinessPickupButton extends StatelessWidget {
  final String userId;
  final double delay;
  const _BusinessPickupButton({required this.userId, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: (400 + delay * 200).round()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/weastPage',
                arguments: {
                  'userId': userId,
                  'userType': 'Business',
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ),
    );
  }
}

LatLng? parseWkbPoint(String? wkbHex) {
  if (wkbHex == null || wkbHex.length != 50) return null;
  try {
    // Convert hex string to bytes
    final bytes = Uint8List(wkbHex.length ~/ 2);
    for (int i = 0; i < wkbHex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(wkbHex.substring(i, i + 2), radix: 16);
    }
    final byteData = ByteData.sublistView(bytes);
    final isLittleEndian = bytes[0] == 1;
    final x = byteData.getFloat64(21, isLittleEndian ? Endian.little : Endian.big);
    final y = byteData.getFloat64(29, isLittleEndian ? Endian.little : Endian.big);
    return LatLng(y, x);
  } catch (_) {
    return null;
  }
}

LatLng? parsePostgisWkbPoint(String? wkbHex) {
  if (wkbHex == null || wkbHex.length != 50) return null;
  try {
    final bytes = Uint8List(wkbHex.length ~/ 2);
    for (int i = 0; i < wkbHex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(wkbHex.substring(i, i + 2), radix: 16);
    }
    final byteData = ByteData.sublistView(bytes);
    // Byte order: 0 = big endian, 1 = little endian
    final isLittleEndian = bytes[0] == 1;
    // X and Y are at offsets 20 and 28 for PostGIS EWKB with SRID
    final x = byteData.getFloat64(20, isLittleEndian ? Endian.little : Endian.big);
    final y = byteData.getFloat64(28, isLittleEndian ? Endian.little : Endian.big);
    return LatLng(y, x);
  } catch (_) {
    return null;
  }
}
