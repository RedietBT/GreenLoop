import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? const Icon(Icons.business, size: 70, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  user.business_name ?? '',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? 'No email available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 30),

                //About us Section
                  Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "About Us",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.description ?? 'No description available.', // Use user.description and handle null
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                 const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Address",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.address ?? 'No Address available.', // Use user.description and handle null
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20), 
                LocationMapPreview(location: user.location),
                const SizedBox(height: 20),
                // Achievements Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Achievements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
                // Placeholder for achievements list (you can replace this with a dynamic list later)
                Container(
                  height: 100,
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

