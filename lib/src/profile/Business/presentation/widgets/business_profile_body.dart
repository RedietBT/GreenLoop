import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'dart:typed_data';
import 'package:latlong2/latlong.dart';

class BusinessProfileBody extends StatefulWidget {
  final String userId; 

  const BusinessProfileBody({super.key, required this.userId});

  @override
  State<BusinessProfileBody> createState() => _BusinessProfileBodyState();
  
}

class _BusinessProfileBodyState extends State<BusinessProfileBody> {
  @override
  void initState() {
    super.initState();

    context.read<BusinessProfileCubit>().fetchUserProfile(widget.userId);
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Duolingo-style colorful header
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                    ? const Icon(Icons.business, size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.business_name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? 'No email available',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                          onPressed: () async {
                            // Use the signOut usecase
                            await context.read<BusinessProfileCubit>().signOut(context, widget.userId as AuthRepo);
                          },
                          tooltip: 'Logout',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Card-like info section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            user.description ?? 'No description available.',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Address",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.address ?? 'No Address available.',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          // Map preview
                          LocationMapPreview(location: location),
                          const SizedBox(height: 16),
                          Text(
                            "Achievements",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No achievements yet.',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
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
