import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
// Ensure your Individual_User entity is imported if needed for direct access to its properties
// import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';

class IndividualProfileBody extends StatelessWidget {
  final String userId;
  const IndividualProfileBody({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<IndividualProfileCubit>().fetchUser(userId);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 1. Top Bar with Avatar, Greeting, Notification
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: state is IndividualProfileLoaded && state.user.avatarUrl != null
                              ? NetworkImage(state.user.avatarUrl!)
                              : null,
                          child: state is! IndividualProfileLoaded || state.user.avatarUrl == null
                              ? Icon(Icons.person, size: 32, color: Colors.black)
                              : null,
                          backgroundColor: Colors.green[800],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Good Afternoon ☀️, ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (state is IndividualProfileLoaded)
                                    Text(
                                      state.user.first_name ?? '',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state is IndividualProfileLoaded
                                    ? state.user.email ?? ''
                                    : '',
                                style: const TextStyle(color: Colors.black54, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.black),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // 2. Location Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'B12kk, Addis Ababa , 1994',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  // 3. Promotional/Image Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Give. Take. Repeat',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text(
                                    'KNOW MORE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 4. Dashboard Title & Share
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Text(
                          'Your Dashboard',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.greenAccent),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // 5. Stat Cards Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: state is IndividualProfileLoaded
                        ? GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                            children: [
                              _dashboardCard(
                                color: Colors.purple,
                                icon: Icons.account_balance_wallet,
                                value: '₹ ${state.user.points ?? 0}',
                                label: 'Earned So Far',
                              ),
                              _dashboardCard(
                                color: Colors.lightGreen,
                                icon: Icons.local_shipping,
                                value: '${state.user.eventsJoined ?? 0}',
                                label: 'Events Joined',
                              ),
                              _dashboardCard(
                                color: Colors.teal,
                                icon: Icons.delete_outline,
                                value: '${state.user.treesPlanted ?? 0}',
                                label: 'Trees Planted',
                              ),
                              _dashboardCard(
                                color: Colors.orange,
                                icon: Icons.military_tech,
                                value: '${state.user.badgesEarned ?? 0}',
                                label: 'Badges Earned',
                              ),
                            ],
                          )
                        : state is IndividualProfileLoading
                            ? const Center(child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ))
                            : state is IndividualProfileError
                                ? Center(child: Text(state.message, style: const TextStyle(color: Colors.red)))
                                : const SizedBox.shrink(),
                  ),
                  // 6. Categories Section
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 8),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      children: [
                        _categoryCard(
                          icon: Icons.tv,
                          label: 'LCD/LED TV',
                          price: '₹ 10/Kg',
                          imageUrl: 'https://cdn-icons-png.flaticon.com/512/3103/3103446.png',
                        ),
                        _categoryCard(
                          icon: Icons.recycling,
                          label: 'LDPE',
                          price: '₹ 13/Kg',
                          imageUrl: 'https://cdn-icons-png.flaticon.com/512/565/565547.png',
                        ),
                        _categoryCard(
                          icon: Icons.laptop_mac,
                          label: 'Laptop',
                          price: '₹ 200/Pc',
                          imageUrl: 'https://cdn-icons-png.flaticon.com/512/1792/1792864.png',
                        ),
                        // Add more categories as needed
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _categoryCard({
    required IconData icon,
    required String label,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.network(imageUrl, height: 36, width: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dashboardCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black.withOpacity(0.8), size: 28),
              const Spacer(),
              if (label == 'Earned So Far')
                const Icon(Icons.attach_money, color: Colors.yellow, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 15,
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

