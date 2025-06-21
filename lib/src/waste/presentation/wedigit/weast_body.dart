import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_cubit.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_state.dart';
import 'package:uuid/uuid.dart';

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
  bool _isSearchingCenters = false;
  String? _generatedWeastId;

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

  void _searchRecyclingCenters() {
    if (_locationController.text.trim().isNotEmpty) {
      setState(() {
        _isSearchingCenters = true;
      });
      
      // Clear previous selection when searching
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
        location: _locationController.text.trim(),
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
            requestStatus: 'pending',
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
                  
                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g., New York, Los Angeles, Chicago',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSearchingCenters)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _isSearchingCenters ? null : _searchRecyclingCenters,
                            tooltip: 'Search for recycling centers',
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _isSearchingCenters ? null : () {
                              _locationController.text = 'Test';
                              _searchRecyclingCenters();
                            },
                            tooltip: 'Test search with "Test"',
                          ),
                        ],
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Recycling Centers Section
                  if (state is RecyclingCentersLoaded || _isSearchingCenters)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Recycling Centers',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isSearchingCenters)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (state is RecyclingCentersLoaded)
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
                            ...state.recyclingCenters.map((center) => 
                              Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: RadioListTile<String>(
                                  value: center.id,
                                  groupValue: _selectedRecyclingCenterId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRecyclingCenterId = value;
                                    });
                                  },
                                  title: Text(center.center_name ?? 'Unknown Center'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (center.email != null)
                                        Text('Email: ${center.email}'),
                                      if (center.phone != null)
                                        Text('Phone: ${center.phone}'),
                                      if (center.address != null)
                                        Text('Address: ${center.address}'),
                                    ],
                                  ),
                                  secondary: const Icon(Icons.recycling),
                                ),
                              ),
                            ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
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
                          '2. Enter your location (city name)\n'
                          '3. Search for available recycling centers\n'
                          '4. Select a recycling center\n'
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