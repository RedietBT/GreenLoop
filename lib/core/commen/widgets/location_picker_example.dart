import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'location_picker_widget.dart';

class LocationPickerExample extends StatefulWidget {
  const LocationPickerExample({Key? key}) : super(key: key);

  @override
  State<LocationPickerExample> createState() => _LocationPickerExampleState();
}

class _LocationPickerExampleState extends State<LocationPickerExample> {
  LatLng? _selectedLocation;
  String _selectedAddress = '';

  void _openLocationPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          onLocationSelected: (location, address) {
            setState(() {
              _selectedLocation = location;
              _selectedAddress = address;
            });
          },
          initialLocation: _selectedLocation,
          initialAddress: _selectedAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _openLocationPicker,
              icon: const Icon(Icons.map),
              label: const Text('Pick Location'),
            ),
            const SizedBox(height: 20),
            if (_selectedLocation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Location:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Address: $_selectedAddress',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No location selected yet. Tap the button above to pick a location.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 