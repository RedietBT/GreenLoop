import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/src/profile/Business/presentation/widgets/location_picker_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class EditBusinessProfilePage extends StatefulWidget {
  final String userId;

  const EditBusinessProfilePage({super.key, required this.userId});

  @override
  State<EditBusinessProfilePage> createState() => _EditBusinessProfilePageState();
}

class _EditBusinessProfilePageState extends State<EditBusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _contactPersonFirstNameController;
  late TextEditingController _contactPersonLastNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  // Latitude and Longitude controllers are now for display only
  late TextEditingController _latitudeDisplayController;
  late TextEditingController _longitudeDisplayController;

  File? _pickedImage;
  String? _currentAvatarUrl;

  String? _originalBusinessName;
  String? _originalContactPersonFirstName;
  String? _originalContactPersonLastName;
  String? _originalPhoneNumber;
  String? _originalEmail;
  String? _originalDescription;
  String? _originalAddress;
  LatLng? _originalLocation; 
  LatLng? _selectedLocationFromMap; 

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _contactPersonFirstNameController = TextEditingController();
    _contactPersonLastNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeDisplayController = TextEditingController();
    _longitudeDisplayController = TextEditingController();

    context.read<BusinessProfileCubit>().fetchUserProfile(widget.userId);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonFirstNameController.dispose();
    _contactPersonLastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeDisplayController.dispose();
    _longitudeDisplayController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _openLocationPicker() async {
    final LatLng? pickedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocationFromMap ?? _originalLocation,
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocationFromMap = pickedLocation;
        _latitudeDisplayController.text = pickedLocation.latitude.toString();
        _longitudeDisplayController.text = pickedLocation.longitude.toString();
      });
    }
  }

  Future<void> _updateProfile() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is empty. Cannot update profile.')),
      );
      return;
    }
    setState(() {
      _updateInProgress = true;
    });

    String? newAvatarUrl = _currentAvatarUrl;
    bool isImageUpdated = false;

    if (_pickedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );
      try {
        newAvatarUrl = await context.read<BusinessProfileCubit>().uploadFile(
              bucketName: 'profile',
              filepath: '${widget.userId}/avatar.jpg',
              file: _pickedImage!,
            );
        isImageUpdated = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        setState(() {
          _updateInProgress = false;
        });
        return;
      }
    }

    bool formIsValid = _formKey.currentState!.validate();

    String? businessNameToUpdate =
        _businessNameController.text != _originalBusinessName ? _businessNameController.text : null;
    String? contactPersonFirstNameToUpdate = _contactPersonFirstNameController.text != _originalContactPersonFirstName
        ? _contactPersonFirstNameController.text
        : null;
    String? contactPersonLastNameToUpdate = _contactPersonLastNameController.text != _originalContactPersonLastName
        ? _contactPersonLastNameController.text
        : null;
    String? phoneNumberToUpdate = _phoneNumberController.text != _originalPhoneNumber ? _phoneNumberController.text : null;
    String? emailToUpdate = _emailController.text != _originalEmail ? _emailController.text : null;
    String? descriptionToUpdate = _descriptionController.text != _originalDescription ? _descriptionController.text : null;
    String? addressToUpdate = _addressController.text != _originalAddress ? _addressController.text : null;

    bool isLocationUpdated = false;
    // Check if location was picked or changed
    if (_selectedLocationFromMap != null) {
      // Location was selected via map
      if (_originalLocation == null ||
          _selectedLocationFromMap!.latitude != _originalLocation!.latitude ||
          _selectedLocationFromMap!.longitude != _originalLocation!.longitude) {
        isLocationUpdated = true;
      }
    } else if (_originalLocation != null &&
               (_latitudeDisplayController.text.isEmpty && _longitudeDisplayController.text.isEmpty)) {
      // Location was cleared (if it existed before and now text fields are empty)
      // This case handles if original location was there, but user cleared the display text field manually
      // which means they want to set location to null.
      isLocationUpdated = true;
      _selectedLocationFromMap = null; // Explicitly set to null for update
    }


    if (!isImageUpdated &&
        businessNameToUpdate == null &&
        contactPersonFirstNameToUpdate == null &&
        contactPersonLastNameToUpdate == null &&
        phoneNumberToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null &&
        addressToUpdate == null &&
        !isLocationUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made to the profile.')),
      );
      setState(() {
        _updateInProgress = false;
      });
      return;
    }

    if ((businessNameToUpdate != null ||
            contactPersonLastNameToUpdate != null ||
            contactPersonFirstNameToUpdate != null ||
            phoneNumberToUpdate != null ||
            emailToUpdate != null ||
            descriptionToUpdate != null ||
            addressToUpdate != null) &&
        !formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct invalid fields.')),
      );
      setState(() {
        _updateInProgress = false;
      });
      return;
    }

    final Map<String, dynamic> updatedData = {
      if (businessNameToUpdate != null) 'business_name': businessNameToUpdate,
      if (contactPersonFirstNameToUpdate != null) 'contact_person_first_name': contactPersonFirstNameToUpdate,
      if (contactPersonLastNameToUpdate != null) 'contact_person_last_name': contactPersonLastNameToUpdate,
      if (phoneNumberToUpdate != null) 'phone_number': phoneNumberToUpdate, // Corrected key to phone_number
      if (emailToUpdate != null) 'email': emailToUpdate,
      if (descriptionToUpdate != null) 'description': descriptionToUpdate,
      if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl, // Corrected key to avatarUrl
      if (addressToUpdate != null) 'address': addressToUpdate,

      // Format location properly for Supabase geometry column
      if (isLocationUpdated) 'location': _selectedLocationFromMap != null
          ? 'SRID=4326;POINT(${_selectedLocationFromMap!.longitude} ${_selectedLocationFromMap!.latitude})'
          : null,
    };

    context.read<BusinessProfileCubit>().updateProfile(
          userId: widget.userId,
          data: updatedData,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile update initiated...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
      ),
      body: BlocListener<BusinessProfileCubit, BusinessProfileState>(
        listener: (context, state) {
          if (state is BusinessProfileLoaded) {
            final business = state.business;
            _businessNameController.text = business.business_name ?? '';
            _contactPersonFirstNameController.text = business.contact_person_first_name ?? '';
            _contactPersonLastNameController.text = business.contact_person_last_name ?? '';
            _phoneNumberController.text = business.phone_number ?? '';
            _emailController.text = business.email ?? '';
            _descriptionController.text = business.description ?? '';
            _addressController.text = business.address ?? '';
            _latitudeDisplayController.text = business.location?.latitude.toString() ?? '';
            _longitudeDisplayController.text = business.location?.longitude.toString() ?? '';

            _originalBusinessName = business.business_name;
            _originalContactPersonFirstName = business.contact_person_first_name;
            _originalContactPersonLastName = business.contact_person_last_name;
            _originalPhoneNumber = business.phone_number;
            _originalEmail = business.email;
            _originalDescription = business.description;
            _originalAddress = business.address;
            _currentAvatarUrl = business.avatarUrl;
            _originalLocation = business.location; 
            _selectedLocationFromMap = business.location;

            _pickedImage = null; 

            if (_updateInProgress) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              Navigator.pop(context, true);
              setState(() {
                _updateInProgress = false;
              });
            }
          } else if (state is BusinessProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${state.message}')),
            );
            setState(() {
              _updateInProgress = false;
            });
          }
        },
        child: BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
          builder: (context, state) {
            if (state is BusinessProfileLoading || state is BusinessProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BusinessProfileError && !_updateInProgress) {
              return Center(child: Text('Error: ${state.message}'));
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? NetworkImage(_currentAvatarUrl!)
                                : null) as ImageProvider<Object>?,
                        child: _pickedImage == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty)
                            ? const Icon(Icons.business, size: 70, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(labelText: 'Business Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactPersonFirstNameController,
                      decoration: const InputDecoration(labelText: 'Contact Person First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _contactPersonLastNameController,
                      decoration: const InputDecoration(labelText: 'Contact Person Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Location Coordinates',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // Display Latitude
                    TextFormField(
                      controller: _latitudeDisplayController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        enabled: false, // Make it read-only
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    // Display Longitude
                    TextFormField(
                      controller: _longitudeDisplayController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        enabled: false, // Make it read-only
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openLocationPicker,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateInProgress ? null : () => _updateProfile(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _updateInProgress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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