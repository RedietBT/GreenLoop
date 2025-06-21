import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_cubit.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_state.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/core/commen/widgets/location_picker_widget.dart';
import 'dart:math';

class WeastBody extends StatefulWidget{
  final String userId;
  const WeastBody({super.key, required this.userId});
  
  @override
  State<WeastBody> createState() => _WeastBodyState();
}

class _WeastBodyState extends State<WeastBody>{
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _selectedRecyclingCenterId;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isSearchingCenters = false;
  bool _showRecyclingCenters = false;
  String? _generatedWeastId;
  LatLng? _selectedLocation;
  bool _hasLocation = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1Rad = point1.latitude * (pi / 180);
    double lat2Rad = point2.latitude * (pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    double deltaLonRad = (point2.longitude - point1.longitude) * (pi / 180);
    
    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedLocation = LatLng(position.latitude, position.longitude);

      // Reverse geocode to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = [
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          
          _locationController.text = address;
        } else {
          // If no address found, use coordinates
          _locationController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (e) {
        // If reverse geocoding fails, use coordinates
        _locationController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      // Always set hasLocation to true when we get coordinates
      setState(() {
        _hasLocation = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location detected successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _pickLocationOnMap() async {
    final LatLng? pickedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          initialLocation: _selectedLocation ?? const LatLng(0, 0),
        ),
      ),
    );

    if (pickedLocation != null) {
      _selectedLocation = pickedLocation;
      
      try {
        // Reverse geocode to get address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pickedLocation.latitude,
          pickedLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = [
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          
          _locationController.text = address;
          setState(() {
            _hasLocation = true;
          });
        }
      } catch (e) {
        // If reverse geocoding fails, just use coordinates
        _locationController.text = '${pickedLocation.latitude.toStringAsFixed(4)}, ${pickedLocation.longitude.toStringAsFixed(4)}';
        setState(() {
          _hasLocation = true;
        });
      }
    }
  }

  void _searchRecyclingCenters() {
    if (_locationController.text.trim().isNotEmpty) {
      setState(() {
        _isSearchingCenters = true;
        _showRecyclingCenters = true;
      });
      
      // Clear previous selection when searching
      _selectedRecyclingCenterId = null;
      
      // If we have a selected location, use closest centers search
      if (_selectedLocation != null) {
        print('Using closest centers search for location: $_selectedLocation');
        context.read<WeastCubit>().fetchClosestRecyclingCenters(_selectedLocation!);
      } else {
        // Fallback to text-based search
        print('Using text-based search for location: ${_locationController.text.trim()}');
        context.read<WeastCubit>().fetchRecyclingCenters(_locationController.text.trim());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location to search for recycling centers'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _searchByLocationName() {
    if (_locationController.text.trim().isNotEmpty) {
      setState(() {
        _isSearchingCenters = true;
        _showRecyclingCenters = true;
      });
      
      _selectedRecyclingCenterId = null;
      context.read<WeastCubit>().fetchRecyclingCenters(_locationController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location to search for recycling centers'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _submitWasteRequest() {
    if (_formKey.currentState!.validate() && _selectedRecyclingCenterId != null) {
      setState(() {
        _isSubmitting = true;
        _generatedWeastId = const Uuid().v4();
      });
      
      // First insert the waste profile
      context.read<WeastCubit>().insertWeast(
        weastId: _generatedWeastId!,
        userId: widget.userId,
        type: _typeController.text.trim(),
        quantity: _quantityController.text.trim(),
        location: _selectedLocation,
      );
    } else if (_selectedRecyclingCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recycling center'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return BlocListener<WeastCubit, WeastState>(
      listener: (context, state) {
        if (state is WeastInserted) {
          // After waste is inserted, request pickup
          final requestId = const Uuid().v4();
          
          context.read<WeastCubit>().requestForPickup(
            id: requestId,
            userId: widget.userId,
            weastId: _generatedWeastId!,
            recyclingCenterId: _selectedRecyclingCenterId!,
            requestStatus: 'PENDING',
          );
        } else if (state is WeastRequestPickup) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waste pickup request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is RecyclingCentersLoaded) {
          setState(() {
            _isSearchingCenters = false;
          });
          
          if (state.recyclingCenters.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No recycling centers found in this location. Try a different city or area.'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found ${state.recyclingCenters.length} recycling center(s)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (state is WeastError) {
          setState(() {
            _isSubmitting = false;
            _isSearchingCenters = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<WeastCubit, WeastState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.recycling,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Request Waste Pickup',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fill in the details below to request a waste pickup from a recycling center',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Waste Type
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Waste Type',
                      hintText: 'e.g., Plastic, Paper, Electronics, Metal',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter waste type';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quantity
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'e.g., 5 kg, 2 bags, 1 box',
                      prefixIcon: Icon(Icons.scale),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Location Input
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Your Location',
                              hintText: 'e.g., New York, Los Angeles, Chicago',
                              prefixIcon: const Icon(Icons.edit_location),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter location';
                              }
                              return null;
                            },
                          ),
                          
                          // Show selected coordinates if available
                          if (_selectedLocation != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Location set: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // Location Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                                  icon: _isGettingLocation 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.my_location),
                                  label: Text(_isGettingLocation ? 'Getting...' : 'Use Current Location'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickLocationOnMap,
                                  icon: const Icon(Icons.map),
                                  label: const Text('Pick on Map'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Choose Recycling Center Button
                  if (_hasLocation)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSearchingCenters ? null : _searchRecyclingCenters,
                            icon: _isSearchingCenters 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.location_on),
                            label: Text(_isSearchingCenters ? 'Searching...' : 'Find Closest Recycling Centers'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isSearchingCenters ? null : _searchByLocationName,
                            icon: _isSearchingCenters 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                            label: const Text('Search by Location Name'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Selected Recycling Center Display
                  if (_selectedRecyclingCenterId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recycling Center Selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Center ID: $_selectedRecyclingCenterId',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedRecyclingCenterId = null;
                              });
                            },
                            icon: const Icon(Icons.edit, color: Colors.green),
                            tooltip: 'Change selection',
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Recycling Centers Section
                  if (_showRecyclingCenters)
                    BlocBuilder<WeastCubit, WeastState>(
                      builder: (context, state) {
                        if (state is RecyclingCentersLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.recycling, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Available Recycling Centers',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showRecyclingCenters = false;
                                        _selectedRecyclingCenterId = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                    tooltip: 'Hide centers',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (state.recyclingCenters.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'No recycling centers found in this location. Try a different city or area.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ...state.recyclingCenters.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final center = entry.value;
                                  final isClosest = index == 0 && _selectedLocation != null;
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: RadioListTile<String>(
                                      value: center.id,
                                      groupValue: _selectedRecyclingCenterId,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRecyclingCenterId = value;
                                        });
                                      },
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              center.center_name ?? 'Unknown Center',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isClosest)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'Closest',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (center.email != null)
                                            Text('Email: ${center.email}'),
                                          if (center.phone != null)
                                            Text('Phone: ${center.phone}'),
                                          if (center.address != null)
                                            Text('Address: ${center.address}'),
                                          if (_selectedLocation != null && center.location != null)
                                            Text(
                                              'Distance: ${_calculateDistance(_selectedLocation!, center.location!).toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                        ],
                                      ),
                                      secondary: const Icon(Icons.recycling, color: AppColors.primary),
                                    ),
                                  );
                                }),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitWasteRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Submitting...'),
                              ],
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Fill in the waste type and quantity\n'
                          '2. Set your location (use current location or pick on map)\n'
                          '3. Choose how to find recycling centers:\n'
                          '   • "Find Closest" - Shows centers sorted by distance\n'
                          '   • "Search by Location Name" - Text-based search\n'
                          '4. Select a recycling center from the list\n'
                          '5. Submit your request\n\n'
                          'The recycling center will contact you to arrange pickup.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}