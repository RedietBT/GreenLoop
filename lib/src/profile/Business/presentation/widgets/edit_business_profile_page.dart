import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';
import 'package:greenloop/core/commen/widgets/location_picker_widget.dart';
import 'package:greenloop/core/commen/widgets/global_footer.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
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
  
  // Footer state management
  int _currentFooterIndex = 0;

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
      _showSnackBar('User ID is empty. Cannot update profile.', isError: true);
      return;
    }
    setState(() {
      _updateInProgress = true;
    });

    String? newAvatarUrl = _currentAvatarUrl;
    bool isImageUpdated = false;

    if (_pickedImage != null) {
      _showSnackBar('Uploading image...');
      try {
        newAvatarUrl = await context.read<BusinessProfileCubit>().uploadFile(
              bucketName: 'profile',
              filepath: '${widget.userId}/avatar.jpg',
              file: _pickedImage!,
            );
        isImageUpdated = true;
        _showSnackBar('Image uploaded successfully!');
      } catch (e) {
        _showSnackBar('Failed to upload image: $e', isError: true);
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
    
      isLocationUpdated = true;
      _selectedLocationFromMap = null; 
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
      _showSnackBar('No changes made to the profile.');
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
      _showSnackBar('Please correct invalid fields.', isError: true);
      setState(() {
        _updateInProgress = false;
      });
      return;
    }

    final Map<String, dynamic> updatedData = {
      if (businessNameToUpdate != null) 'business_name': businessNameToUpdate,
      if (contactPersonFirstNameToUpdate != null) 'contact_person_first_name': contactPersonFirstNameToUpdate,
      if (contactPersonLastNameToUpdate != null) 'contact_person_last_name': contactPersonLastNameToUpdate,
      if (phoneNumberToUpdate != null) 'phone': phoneNumberToUpdate,
      if (emailToUpdate != null) 'email': emailToUpdate,
      if (descriptionToUpdate != null) 'description': descriptionToUpdate,
      if (newAvatarUrl != null) 'avater_url': newAvatarUrl,
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

    _showSnackBar('Profile update initiated...');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _onFooterTap(int index) {
    setState(() {
      _currentFooterIndex = index;
    });
    
    switch (index) {
      case 0: // Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/businessProfile',
          arguments: {'userId': widget.userId, 'userType': 'Business'},
          (route) => false,
        );
        break;
      case 1: // AI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI feature coming soon!')),
        );
        break;
      case 2: // Logout
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color borderColor = isDark ? AppColors.accent : AppColors.primary;
    
    return _PageEntranceAnimation(
      child: Scaffold(
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
              'Edit Business Profile',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: Fonts.fontFamilyBold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
          foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : AppColors.textPrimary,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
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
                _showSnackBar('Profile updated successfully!');
                Navigator.pop(context, true);
                setState(() {
                  _updateInProgress = false;
                });
              }
            } else if (state is BusinessProfileError) {
              _showSnackBar('Profile update failed: ${state.message}', isError: true);
              setState(() {
                _updateInProgress = false;
              });
            }
          },
          child: BlocBuilder<BusinessProfileCubit, BusinessProfileState>(
            builder: (context, state) {
              if (state is BusinessProfileLoading || state is BusinessProfileInitial||
              state is BusinessProfileUpdating) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BusinessProfileError && !_updateInProgress) {
                return Center(child: Text('Error: ${state.message}', style: TextStyle(color: textColor)));
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
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: CircleAvatar(
                                      key: ValueKey(_pickedImage?.path ?? _currentAvatarUrl ?? 'default'),
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: _BouncyCameraIcon(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            _AnimatedFormField(
                              controller: _businessNameController,
                              label: 'Business Name',
                              icon: Icons.business,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter business name';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _contactPersonFirstNameController,
                              label: 'Contact Person First Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter first name';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _contactPersonLastNameController,
                              label: 'Contact Person Last Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter last name';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _phoneNumberController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _addressController,
                              label: 'Address',
                              icon: Icons.location_city_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your address';
                                }
                                return null;
                              },
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _latitudeDisplayController,
                              label: 'Latitude',
                              icon: Icons.location_on_outlined,
                              enabled: false,
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _longitudeDisplayController,
                              label: 'Longitude',
                              icon: Icons.location_on_outlined,
                              enabled: false,
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 8),
                            _AnimatedLocationPickerButton(
                              onPick: _openLocationPicker,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _AnimatedFormField(
                              controller: _descriptionController,
                              label: 'About Us',
                              icon: Icons.info_outline,
                              maxLines: 3,
                              isDark: isDark,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 24),
                            _AnimatedSaveButton(
                              isLoading: _updateInProgress,
                              onTap: _updateProfile,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 20),
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
      ),
    );
  }
}

class _BouncyCameraIcon extends StatefulWidget {
  @override
  State<_BouncyCameraIcon> createState() => _BouncyCameraIconState();
}

class _BouncyCameraIconState extends State<_BouncyCameraIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTap() {
    _controller.forward(from: 0.8);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _controller,
        child: CircleAvatar(
          backgroundColor: Theme.of(context).cardColor,
          radius: 20,
          child: Icon(
            Icons.camera_alt,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class _AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool isDark;
  final Color borderColor;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  const _AnimatedFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    required this.isDark,
    required this.borderColor,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
  });
  @override
  State<_AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<_AnimatedFormField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) => setState(() => _focused = focus),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: widget.borderColor.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              labelText: widget.label,
              prefixIcon: Icon(widget.icon, color: widget.borderColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.borderColor, width: 2.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.borderColor, width: 2.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.borderColor, width: 2.2),
              ),
              fillColor: widget.isDark ? const Color(0xFF232A28) : Colors.white,
              filled: true,
              labelStyle: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}

class _AnimatedSaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final bool isDark;
  const _AnimatedSaveButton({required this.isLoading, required this.onTap, required this.isDark});
  @override
  State<_AnimatedSaveButton> createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }
  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    widget.onTap();
  }
  void _onTapCancel() {
    _controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.primary : AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? AppColors.accent : AppColors.primary).withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

// Page-level entrance animation
class _PageEntranceAnimation extends StatefulWidget {
  final Widget child;
  const _PageEntranceAnimation({required this.child});
  @override
  State<_PageEntranceAnimation> createState() => _PageEntranceAnimationState();
}

class _PageEntranceAnimationState extends State<_PageEntranceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(_fade);
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// Animated location picker button
class _AnimatedLocationPickerButton extends StatefulWidget {
  final VoidCallback onPick;
  final bool isDark;
  const _AnimatedLocationPickerButton({required this.onPick, required this.isDark});
  @override
  State<_AnimatedLocationPickerButton> createState() => _AnimatedLocationPickerButtonState();
}

class _AnimatedLocationPickerButtonState extends State<_AnimatedLocationPickerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }
  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    widget.onPick();
  }
  void _onTapCancel() {
    _controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.primary : AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? AppColors.accent : AppColors.primary).withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.map, color: Colors.white),
              SizedBox(width: 10),
              Text('Pick Location on Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
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