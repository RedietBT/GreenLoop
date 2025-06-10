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

    if (!imageUploaded &&
        firstNameToUpdate == null &&
        lastNameToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0, // Flat app bar
      ),
      body: BlocListener<IndividualProfileCubit, IndividualProfileState>(
        listener: (context, state) {
          if (state is IndividualProfileLoaded) {
            final user = state.user;
            _firstNameController.text = user.first_name ?? '';
            _lastNameController.text = user.last_name ?? '';
            _emailController.text = user.email ?? '';
            _descriptionController.text = user.description ?? '';

            _originalFirstName = user.first_name;
            _originalLastName = user.last_name;
            _originalEmail = user.email;
            _originalDescription = user.description;
            _currentAvatarUrl = user.avatarUrl;
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.7),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (_currentAvatarUrl != null &&
                                        _currentAvatarUrl!.isNotEmpty
                                    ? NetworkImage(_currentAvatarUrl!)
                                    : null) as ImageProvider<Object>?,
                            child: _pickedImage == null &&
                                    (_currentAvatarUrl == null ||
                                        _currentAvatarUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 70, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: const Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateInProgress ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                        child: _updateInProgress
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 18),
                              ),
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