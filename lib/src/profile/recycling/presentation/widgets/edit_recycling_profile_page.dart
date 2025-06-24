import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_picker_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/core/commen/widgets/global_footer.dart';

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
  int _currentFooterIndex = 0;

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
        builder: (context) => LocationPickerWidget(
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

  void _onFooterTap(int index) {
    setState(() {
      _currentFooterIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/ai');
        break;
      case 2:
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Poppins-Bold',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: BackButton(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    backgroundImage: _pickedImage != null
                                        ? FileImage(_pickedImage!)
                                        : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                              ? NetworkImage(_currentAvatarUrl!)
                                              : null) as ImageProvider<Object>?,
                                    child: _pickedImage == null &&
                                            (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty)
                                        ? const Icon(Icons.camera_alt, size: 70, color: AppColors.primary)
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _styledTextField(_centerNameController, 'Center Name', validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the center name';
                            }
                            return null;
                          }),
                          const SizedBox(height: 16),
                          _styledTextField(_contactPersonFirstNameController, 'Contact Person First Name', validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter contact person first name';
                            }
                            return null;
                          }),
                          const SizedBox(height: 16),
                          _styledTextField(_contactPersonLastNameController, 'Contact Person Last Name', validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter contact person last name';
                            }
                            return null;
                          }),
                          const SizedBox(height: 16),
                          _styledTextField(_emailController, 'Email',
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
                          _styledTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
                          const SizedBox(height: 16),
                          _styledTextField(_addressController, 'Address', maxLines: 3),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _styledTextField(_latitudeDisplayController, 'Latitude',
                                  enabled: false,
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _styledTextField(_longitudeDisplayController, 'Longitude',
                                  enabled: false,
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openLocationPicker,
                            icon: const Icon(Icons.map),
                            label: const Text('Pick Location on Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _styledTextField(_descriptionController, 'Description', maxLines: 5),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateInProgress ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              child: _updateInProgress
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GlobalFooter(
                    currentIndex: _currentFooterIndex,
                    onTap: _onFooterTap,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _styledTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontFamily: Fonts.fontFamily,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontFamily: Fonts.fontFamilyBold,
        ),
        filled: true,
        fillColor: isDark ? AppColors.cardBackgroundDark : Colors.white,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
} 