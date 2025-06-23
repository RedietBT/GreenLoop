import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/src/pickup_request/presentation/views/pickup_requests_screen.dart';


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
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  backgroundImage: user.avatar_url != null && user.avatar_url!.isNotEmpty
                      ? NetworkImage(user.avatar_url!)
                      : null,
                  child: user.avatar_url == null || user.avatar_url!.isEmpty
                      ? const Icon(Icons.business, size: 70, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  user.center_name ?? 'Recycling Center Name',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'No email available',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.phone ?? 'No phone available',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard(
                        context, Icons.pending_actions, 'Pending Requests', '0'),
                    _buildSummaryCard(
                        context, Icons.check_circle, 'Completed Pickups', '0'),
                  ],
                ),
                const SizedBox(height: 20),

                // View Requests Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickupRequestsScreen(
                          recyclingCenterId: user.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Pickup Requests'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Address Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.address ?? 'No address available.',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Location Coordinates Card
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: LocationMapPreview(location: location),
                ),

                const SizedBox(height: 30),

                // Description Section (About Us)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Us",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.description ?? 'No description available.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Placeholder for additional Recycling Center details (e.g., operating hours, services)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Services & Hours",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No specific services or hours listed yet.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
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

  Widget _buildSummaryCard(
      BuildContext context, IconData icon, String title, String count) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(count,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}