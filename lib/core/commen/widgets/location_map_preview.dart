import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMapPreview extends StatelessWidget {
  final LatLng? location;
  final double height;
  final double zoom;

  const LocationMapPreview({
    Key? key,
    required this.location,
    this.height = 180,
    this.zoom = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return Container(
        height: height,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('No location set.'),
      );
    }
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location!,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // disables all gestures
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.greenloop',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 