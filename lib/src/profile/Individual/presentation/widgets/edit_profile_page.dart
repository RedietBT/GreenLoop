import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greenloop/core/commen/widgets/location_picker_widget.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeDisplayController;
  late TextEditingController _longitudeDisplayController;

  File? _pickedImage;
  String? _currentAvatarUrl;

  String? _originalFirstName;
  String? _originalLastName;
  String? _originalEmail;
  String? _originalDescription;
  LatLng? _originalLocation;
  LatLng? _selectedLocationFromMap;

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
    _latitudeDisplayController = TextEditingController();
    _longitudeDisplayController = TextEditingController();

    // Fetch initial user data to populate the fields when the page loads
    context.read<IndividualProfileCubit>().fetchUser(widget.userId);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
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


  Future<void> _updateProfile() async {
    if (widget.userId.isEmpty) {
      _showSnackBar('User ID not found. Cannot update profile.', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please correct invalid fields.', isError: true);
      return;
    }

    setState(() {
      _updateInProgress = true;
    });

    String? newAvatarUrl = _currentAvatarUrl;
    bool imageUploaded = false;

    if (_pickedImage != null) {
      _showSnackBar('Uploading image...');
      try {
        newAvatarUrl = await context.read<IndividualProfileCubit>().uploadFile(
              bucketName: 'profile',
              filepath: '${widget.userId}/avatar.jpg',
              file: _pickedImage!,
            );
        _showSnackBar('Image uploaded successfully!');
        imageUploaded = true;
      } catch (e) {
        _showSnackBar('Failed to upload image: $e', isError: true);
        setState(() {
          _updateInProgress = false;
        });
        return;
      }
    }

    String? firstNameToUpdate =
        _firstNameController.text.trim() != _originalFirstName
            ? _firstNameController.text.trim()
            : null;
    String? lastNameToUpdate =
        _lastNameController.text.trim() != _originalLastName
            ? _lastNameController.text.trim()
            : null;
    String? emailToUpdate = _emailController.text.trim() != _originalEmail
        ? _emailController.text.trim()
        : null;
    String? descriptionToUpdate =
        _descriptionController.text.trim() != _originalDescription
            ? (_descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim())
            : null;

    bool isLocationUpdated = false;
    // Compose location in WKT format
    String? locationWkt;
    final latitude = double.tryParse(_latitudeDisplayController.text);
    final longitude = double.tryParse(_longitudeDisplayController.text);
    if (latitude != null && longitude != null) {
      locationWkt = 'SRID=4326;POINT($longitude $latitude)';
    }
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
        firstNameToUpdate == null &&
        lastNameToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null &&
        !isLocationUpdated) {
      _showSnackBar('No changes to save.');
      setState(() {
        _updateInProgress = false;
      });
      return;
    }

    final Map<String, dynamic> updateData = {};

    if (firstNameToUpdate != null) {
      updateData['first_name'] = firstNameToUpdate;
    }
    if (lastNameToUpdate != null) {
      updateData['last_name'] = lastNameToUpdate;
    }
    if (emailToUpdate != null) {
      updateData['email'] = emailToUpdate;
    }
    if (descriptionToUpdate != null) {
      updateData['description'] = descriptionToUpdate;
    }
    if (imageUploaded && newAvatarUrl != null) {
      updateData['avatar_url'] = newAvatarUrl;
    }
    if (isLocationUpdated) {
      updateData['location'] = locationWkt;
    }

    context.read<IndividualProfileCubit>().updateProfile(
          userId: widget.userId,
          data: updateData,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color borderColor = isDark ? AppColors.accent : AppColors.primary;
    return _PageEntranceAnimation(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
        body: BlocListener<IndividualProfileCubit, IndividualProfileState>(
          listener: (context, state) {
            if (state is IndividualProfileLoaded) {
              final user = state.user;
              _firstNameController.text = user.first_name ?? '';
              _lastNameController.text = user.last_name ?? '';
              _emailController.text = user.email ?? '';
              _descriptionController.text = user.description ?? '';
              _latitudeDisplayController.text = user.location?.latitude.toString() ?? '';
              _longitudeDisplayController.text = user.location?.longitude.toString() ?? '';

              _originalFirstName = user.first_name;
              _originalLastName = user.last_name;
              _originalEmail = user.email;
              _originalDescription = user.description;
              _currentAvatarUrl = user.avatarUrl;
              _originalLocation = user.location;
              _selectedLocationFromMap = user.location;
              _pickedImage = null; // Clear picked image after successful update

              if (_updateInProgress) {
                _showSnackBar('Profile updated successfully!', isError: false);
                Navigator.pop(context, true); // Pop with `true` to signal success
                setState(() {
                  _updateInProgress = false;
                });
              }
            } else if (state is IndividualProfileError) {
              _showSnackBar('Profile update failed: ${state.message}',
                  isError: true);
              setState(() {
                _updateInProgress = false;
              });
            }
          },
          child: BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
            builder: (context, state) {
              if (state is IndividualProfileLoading ||
                  state is IndividualProfileInitial ||
                  state is IndividualProfileUpdating) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is IndividualProfileError && !_updateInProgress) {
                return Center(child: Text('Error loading profile: ${state.message}', style: TextStyle(color: textColor)));
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
                                    ? const Icon(Icons.person, size: 70, color: Colors.white)
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
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        isDark: isDark,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),
                      _AnimatedFormField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your last name';
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
                        onPick: () async {
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
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _AnimatedFormField(
                        controller: _descriptionController,
                        label: 'About Me',
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
                    ],
                  ),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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

LatLng? parsePostgisWkbPoint(String? wkbHex) {
  if (wkbHex == null || wkbHex.length != 50) return null;
  try {
    final bytes = Uint8List(wkbHex.length ~/ 2);
    for (int i = 0; i < wkbHex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(wkbHex.substring(i, i + 2), radix: 16);
    }
    final byteData = ByteData.sublistView(bytes);
    final isLittleEndian = bytes[0] == 1;
    final x = byteData.getFloat64(20, isLittleEndian ? Endian.little : Endian.big);
    final y = byteData.getFloat64(28, isLittleEndian ? Endian.little : Endian.big);
    return LatLng(y, x);
  } catch (_) {
    return null;
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
