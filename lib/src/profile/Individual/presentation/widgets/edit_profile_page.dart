// src/profile/Individual/presentation/pages/edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _pickedImage;
  String? _currentAvatarUrl;

  String? _originalFirstName;
  String? _originalLastName;
  String? _originalEmail;
  String? _originalDescription;

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch initial user data to populate the fields when the page loads
    // This uses the SAME cubit instance passed via BlocProvider.value
    context.read<IndividualProfileCubit>().fetchUser(widget.userId);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
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
        // Ensure your uploadFile method accepts `filepath` which includes a filename.
        // For example: '${widget.userId}/avatar.jpg'
        newAvatarUrl = await context.read<IndividualProfileCubit>().uploadFile(
          bucketName: 'profile',
          filepath: '${widget.userId}/avatar.jpg', // Ensure this is a proper path + filename
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

    String? firstNameToUpdate = _firstNameController.text != _originalFirstName ? _firstNameController.text : null;
    String? lastNameToUpdate = _lastNameController.text != _originalLastName ? _lastNameController.text : null;
    String? emailToUpdate = _emailController.text != _originalEmail ? _emailController.text : null;
    String? descriptionToUpdate = _descriptionController.text != _originalDescription
        ? (_descriptionController.text.isEmpty ? null : _descriptionController.text)
        : null;

    if (!imageUploaded &&
        firstNameToUpdate == null &&
        lastNameToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      setState(() { _updateInProgress = false; });
      return;
    }

    if ((firstNameToUpdate != null || lastNameToUpdate != null || emailToUpdate != null || descriptionToUpdate != null) && !formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct invalid fields.')),
      );
      setState(() { _updateInProgress = false; });
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

    context.read<IndividualProfileCubit>().updateProfile(
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
        title: const Text('Edit Profile'),
      ),
      body: BlocListener<IndividualProfileCubit, IndividualProfileState>(
        listener: (context, state) {
          if (state is IndividualProfileLoaded) {
            final user = state.user;
            _firstNameController.text = user.first_name?? '';
            _lastNameController.text = user.last_name?? '';
            _emailController.text = user.email ?? '';
            _descriptionController.text = user.description ?? '';

            _originalFirstName = user.first_name;
            _originalLastName = user.last_name;
            _originalEmail = user.email;
            _originalDescription = user.description;
            _currentAvatarUrl = user.avatarUrl;
            _pickedImage = null;

            if (_updateInProgress) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              // Pop with `true` to signal success to the previous page
              Navigator.pop(context, true);
              setState(() {
                _updateInProgress = false;
              });
            }
          } else if (state is IndividualProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${state.message}')),
            );
            setState(() {
              _updateInProgress = false;
            });
          }
        },
        child: BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
          builder: (context, state) {
            if (state is IndividualProfileLoading || state is IndividualProfileInitial || state is IndividualProfileUpdating) {
              // Show loading for initial load and during update
              return const Center(child: CircularProgressIndicator());
            }

            if (state is IndividualProfileError && !_updateInProgress) {
              // Only show error message if it's not during an update (which is handled by listener)
              return Center(child: Text('Error loading profile: ${state.message}'));
            }

            // Render the form only when data is loaded (or error, but form still useful)
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
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
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
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateInProgress ? null : _updateProfile,
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