import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch initial user data to populate the fields
    final state = context.read<IndividualProfileCubit>().state;
    if (state is IndividualProfileLoaded) {
      final user = state.user;
      _firstNameController.text = user.first_name ?? '';
      _lastNameController.text = user.last_name ?? '';
      _emailController.text = user.email ?? '';
      _descriptionController.text = user.description ?? '';
      _currentAvatarUrl = user.avatarUrl;
      _userId = user.id; // Assuming user.id exists in your IndividualUser model
    }
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Cannot update profile.')),
        );
        return;
      }

      String? newAvatarUrl = _currentAvatarUrl;

      // If a new image is picked, upload it first
      if (_pickedImage != null) {
        try {
          // You might want to generate a unique filename for the image
          final fileName = 'avatar_${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          newAvatarUrl = await context.read<IndividualProfileCubit>().uploadFile(
                bucketName: 'profile', // Your Supabase bucket name
                filepath: fileName,
                file: _pickedImage!,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          return; // Stop if image upload fails
        }
      }

      // Update the user profile with the new details and avatar URL
      context.read<IndividualProfileCubit>().updateProfile(
            userId: _userId!,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            avatarUrl: newAvatarUrl,
            points: null, // Keep existing points, or handle as needed
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update initiated...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: BlocListener<IndividualProfileCubit, IndividualProfileState>(
        listener: (context, state) {
          if (state is IndividualProfileUpdating) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Updating profile...')),
            );
          } else if (state is IndividualProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context); // Go back after successful update
          } else if (state is IndividualProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${state.message}')),
            );
          }
        },
        child: BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
          builder: (context, state) {
            if (state is IndividualProfileLoading) {
              return const Center(child: CircularProgressIndicator());
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
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
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