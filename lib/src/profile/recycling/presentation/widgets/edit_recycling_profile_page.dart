import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';
import 'package:greenloop/src/profile/recycling/presentation/widgets/location_picker_screen.dart';
import 'package:image_picker/image_picker.dart';

class EditRecyclingProfilePage extends StatefulWidget {
  final String userId;

  const EditRecyclingProfilePage({super.key, required this.userId});

  @override
  State<EditRecyclingProfilePage> createState() => _EditRecyclingProfilePageState();
}

class _EditRecyclingProfilePageState extends State<EditRecyclingProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _centerNameController;
  late TextEditingController _contactPersonFirstNameController;
  late TextEditingController _contactPersonLastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeDisplayController;
  late TextEditingController _longitudeDisplayController;

  File? _pickedImage;
  String? _currentAvatarUrl;

  String? _originalCenterName;
  String? _originalContactPersonFirstName;
  String? _originalContactPersonLastName;
  String? _originalEmail;
  String? _originalPhone;
  String? _originalAddress;
  String? _originalDescription;
  LatLng? _originalLocation;
  LatLng? _selectedLocationFromMap;

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _centerNameController = TextEditingController();
    _contactPersonFirstNameController = TextEditingController();
    _contactPersonLastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _latitudeDisplayController = TextEditingController();
    _longitudeDisplayController = TextEditingController();

    context.read<RecyclingProfileCubit>().fetchUser(widget.userId);
  }

  @override
  void dispose() {
    _centerNameController.dispose();
    _contactPersonFirstNameController.dispose();
    _contactPersonLastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
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
        builder: (context) => RecyclingLocationPickerScreen(
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
        const SnackBar(content: Text('User ID not found. Cannot update profile.')),
      );
      return;
    }

    setState(() {
      _updateInProgress = true;
    });

    String? newAvatarUrl = _currentAvatarUrl;
    bool imageUploaded = false;

    if (_pickedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );
      try {
        newAvatarUrl = await context.read<RecyclingProfileCubit>().uploadFile(
          bucketName: 'profile',
          filepath: '${widget.userId}/avatar.jpg',
          file: _pickedImage!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
        imageUploaded = true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        setState(() { _updateInProgress = false; });
        return;
      }
    }

    bool formIsValid = _formKey.currentState!.validate();

    String? centerNameToUpdate = _centerNameController.text != _originalCenterName ? _centerNameController.text : null;
    String? contactPersonFirstNameToUpdate = _contactPersonFirstNameController.text != _originalContactPersonFirstName ? _contactPersonFirstNameController.text : null;
    String? contactPersonLastNameToUpdate = _contactPersonLastNameController.text != _originalContactPersonLastName ? _contactPersonLastNameController.text : null;
    String? emailToUpdate = _emailController.text != _originalEmail ? _emailController.text : null;
    String? phoneToUpdate = _phoneController.text != _originalPhone ? _phoneController.text : null;
    String? addressToUpdate = _addressController.text != _originalAddress ? _addressController.text : null;
    String? descriptionToUpdate = _descriptionController.text != _originalDescription
        ? (_descriptionController.text.isEmpty ? null : _descriptionController.text)
        : null;

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
      // Location was cleared
      isLocationUpdated = true;
      _selectedLocationFromMap = null;
    }

    if (!imageUploaded &&
        centerNameToUpdate == null &&
        contactPersonFirstNameToUpdate == null &&
        contactPersonLastNameToUpdate == null &&
        emailToUpdate == null &&
        phoneToUpdate == null &&
        addressToUpdate == null &&
        descriptionToUpdate == null &&
        !isLocationUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      setState(() { _updateInProgress = false; });
      return;
    }

    if ((centerNameToUpdate != null ||
            contactPersonFirstNameToUpdate != null ||
            contactPersonLastNameToUpdate != null ||
            emailToUpdate != null ||
            phoneToUpdate != null ||
            addressToUpdate != null ||
            descriptionToUpdate != null) && !formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct invalid fields.')),
      );
      setState(() { _updateInProgress = false; });
      return;
    }

    final Map<String, dynamic> updateData = {};

    if (centerNameToUpdate != null) {
      updateData['center_name'] = centerNameToUpdate;
    }
    if (contactPersonFirstNameToUpdate != null) {
      updateData['contact_person_first_name'] = contactPersonFirstNameToUpdate;
    }
    if (contactPersonLastNameToUpdate != null) {
      updateData['contact_person_last_name'] = contactPersonLastNameToUpdate;
    }
    if (emailToUpdate != null) {
      updateData['email'] = emailToUpdate;
    }
    if (phoneToUpdate != null) {
      updateData['phone'] = phoneToUpdate;
    }
    if (addressToUpdate != null) {
      updateData['address'] = addressToUpdate;
    }
    if (descriptionToUpdate != null) {
      updateData['description'] = descriptionToUpdate;
    }
    if (imageUploaded && newAvatarUrl != null) {
      updateData['avater_url'] = newAvatarUrl;
    }
    if (isLocationUpdated) {
      updateData['location'] = _selectedLocationFromMap != null
          ? 'SRID=4326;POINT(${_selectedLocationFromMap!.longitude} ${_selectedLocationFromMap!.latitude})'
          : null;
    }

    context.read<RecyclingProfileCubit>().updateProfile(
      userId: widget.userId,
      data: updateData,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile update initiated...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recycling Profile'),
      ),
      body: BlocListener<RecyclingProfileCubit, RecyclingProfileState>(
        listener: (context, state) {
          if (state is RecyclingProfileLoaded) {
            final user = state.user;
            _centerNameController.text = user.center_name ?? '';
            _contactPersonFirstNameController.text = user.contact_person_first_name ?? '';
            _contactPersonLastNameController.text = user.contact_person_last_name ?? '';
            _emailController.text = user.email ?? '';
            _phoneController.text = user.phone ?? '';
            _addressController.text = user.address ?? '';
            _descriptionController.text = user.description ?? '';
            _latitudeDisplayController.text = user.location?.latitude.toString() ?? '';
            _longitudeDisplayController.text = user.location?.longitude.toString() ?? '';

            _originalCenterName = user.center_name;
            _originalContactPersonFirstName = user.contact_person_first_name;
            _originalContactPersonLastName = user.contact_person_last_name;
            _originalEmail = user.email;
            _originalPhone = user.phone;
            _originalAddress = user.address;
            _originalDescription = user.description;
            _currentAvatarUrl = user.avatar_url;
            _originalLocation = user.location;
            _selectedLocationFromMap = user.location;
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
          } else if (state is RecyclingProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${state.message}')),
            );
            setState(() {
              _updateInProgress = false;
            });
          }
        },
        child: BlocBuilder<RecyclingProfileCubit, RecyclingProfileState>(
          builder: (context, state) {
            if (state is RecyclingProfileLoading || state is RecyclingProfileInitial || state is RecyclingProfileUpdating) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecyclingProfileError && !_updateInProgress) {
              return Center(child: Text('Error loading profile: ${state.message}'));
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
                        child: _pickedImage == null &&
                                (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 70, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _centerNameController,
                      decoration: const InputDecoration(labelText: 'Center Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the center name';
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
                          return 'Please enter contact person first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactPersonLastNameController,
                      decoration: const InputDecoration(labelText: 'Contact Person Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact person last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Display Fields (Read-only)
                    TextFormField(
                      controller: _latitudeDisplayController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        enabled: false,
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _longitudeDisplayController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        enabled: false,
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Picker Button
                    ElevatedButton.icon(
                      onPressed: _openLocationPicker,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateInProgress ? null : _updateProfile,
                      child: _updateInProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes'),
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