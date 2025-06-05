import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';
import 'package:image_picker/image_picker.dart'; 

class EditProfilePage extends StatefulWidget {
  final String userId; // Add this parameter

  const EditProfilePage({super.key, required this.userId}); // Update constructor

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
  String? _currentAvatarUrl; // This will hold the URL currently displayed or fetched

  // Store original values for comparison
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalEmail;
  String? _originalDescription;

  // IMPORTANT: Flag to track if an update operation was initiated by the user
  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch initial user data to populate the fields when the page loads
    // The cubit was created in the BlocProvider before this page, so it's available.
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
    if (widget.userId.isEmpty) { // Use widget.userId from the widget property
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Cannot update profile.')),
      );
      return;
    }

    // Set the flag to true at the beginning of an update attempt
    // This will disable the button and tell the listener this is an update.
    setState(() {
      _updateInProgress = true;
    });

    String? newAvatarUrl = _currentAvatarUrl;
    bool imageUploaded = false;

    // --- 1. Handle Image Upload First
    if (_pickedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );
      try {
        final fileName = 'avatar_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        newAvatarUrl = await context.read<IndividualProfileCubit>().uploadFile(
              bucketName: 'profile',
              filepath: fileName,
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
        setState(() { _updateInProgress = false; }); // Reset flag on error
        return; // Stop if image upload fails
      }
    }

    // --- 2. Validate text fields
    bool formIsValid = _formKey.currentState!.validate();

    // Determine which text fields have actually changed
    String? firstNameToUpdate = _firstNameController.text != _originalFirstName ? _firstNameController.text : null;
    String? lastNameToUpdate = _lastNameController.text != _originalLastName ? _lastNameController.text : null;
    String? emailToUpdate = _emailController.text != _originalEmail ? _emailController.text : null;
    String? descriptionToUpdate = _descriptionController.text != _originalDescription
        ? (_descriptionController.text.isEmpty ? null : _descriptionController.text)
        : null;

    // Check if any actual update is needed (image or text fields)
    if (!imageUploaded &&
        firstNameToUpdate == null &&
        lastNameToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      setState(() { _updateInProgress = false; }); // Reset flag if no changes
      return; // No changes, so no update necessary
    }

    // If there are text field changes, ensure the form is valid.
    if (!formIsValid && (firstNameToUpdate != null || lastNameToUpdate != null || emailToUpdate != null || descriptionToUpdate != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct invalid fields.')),
      );
      setState(() { _updateInProgress = false; }); // Reset flag on validation failure
      return;
    }

    // --- 3. Call updateProfile with only the changed values
    context.read<IndividualProfileCubit>().updateProfile(
          userId: widget.userId, // Use widget.userId here
          firstName: firstNameToUpdate,
          lastName: lastNameToUpdate,
          email: emailToUpdate,
          avatarUrl: imageUploaded ? newAvatarUrl : null, // Only send avatarUrl if it was just uploaded
          points: null, // Keep existing points, or handle as needed
          description: descriptionToUpdate,
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
            // This listener will be called for initial load AND after a successful update.
            // We need to differentiate based on our _updateInProgress flag.

            // Always update the text controllers and original values to reflect the latest user data
            // (either initial load or successful update).
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
            _pickedImage = null; // Clear picked image if update includes image

            // ONLY pop and show "updated successfully" if an update was in progress
            if (_updateInProgress) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              Navigator.pop(context); // Go back after successful update
              // Reset the flag after handling the successful update
              setState(() {
                _updateInProgress = false;
              });
            }
            // If _updateInProgress is false, it means this IndividualProfileLoaded
            // state came from the initial fetch, so we just populate the fields.
          } else if (state is IndividualProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${state.message}')),
            );
            // Reset the flag if an error occurred during an initiated update
            setState(() {
              _updateInProgress = false;
            });
          }
          // No specific action for IndividualProfileUpdating in listener,
          // the initial "Profile update initiated..." snackbar already gives feedback.
        },
        child: BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
          builder: (context, state) {
            if (state is IndividualProfileLoading || state is IndividualProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is IndividualProfileError && !_updateInProgress) {
              // Show error on initial load failure, but don't prevent showing the form if
              // the error happened during an update (which is handled by the listener).
              return Center(child: Text('Error loading profile: ${state.message}'));
            }

            // The controller values are primarily set in initState (initial load) and BlocListener (updates).
            // No need for redundant setting in the builder, but keep the `CircleAvatar` logic based on `_currentAvatarUrl`.

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
                      // Disable button while update is in progress to prevent multiple submissions
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