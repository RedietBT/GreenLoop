import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _pickedImage;
  String? _currentavatarUrl;

  String? _originalbusinessName;
  String? _originalcontactPersonFirstName;
  String? _originalcontactPersonLastName;
  String? _originalphoneNumber;
  String? _originalemail;
  String? _originaldescription;
  String? _originaladdress;

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

Future<void>  _updateProfile() async{
  if (widget.userId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User ID is empty. Cannot update profile.')),
    );
    return;
  }
  setState(() {
    _updateInProgress = true;
  });

  String? newAvatarUrl = _currentavatarUrl;
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
    }catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        setState(() { _updateInProgress = false; });
        return;
      }
    }
    bool formIsValid = _formKey.currentState!.validate();

    String? businessNameToUpdate = _businessNameController.text != _originalbusinessName
        ? _businessNameController.text: null;
    String? contactPersonFirstNameToUpdate = _contactPersonFirstNameController.text != _originalcontactPersonFirstName ? _contactPersonFirstNameController.text: null;
    String? contactPersonLastNameToUpdate = _contactPersonLastNameController.text != _originalcontactPersonLastName ? _contactPersonLastNameController.text: null;
    String? phoneNumberToUpdate = _phoneNumberController.text != _originalphoneNumber ? _phoneNumberController.text: null;
    String? emailToUpdate = _emailController.text != _originalemail ? _emailController.text: null;
    String? descriptionToUpdate = _descriptionController.text != _originaldescription ? _descriptionController.text: null;
    String? addressToUpdate = _addressController.text != _originaladdress ? _addressController.text: null;

    if(!isImageUpdated &&
        businessNameToUpdate == null &&
        contactPersonFirstNameToUpdate == null &&
        contactPersonLastNameToUpdate == null &&
        phoneNumberToUpdate == null &&
        emailToUpdate == null &&
        descriptionToUpdate == null &&
        addressToUpdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made to the profile.')),
      );
      setState(() {
        _updateInProgress = false;
      });
      return;
    }

    if((businessNameToUpdate != null || contactPersonLastNameToUpdate != null ||
        contactPersonFirstNameToUpdate != null || phoneNumberToUpdate != null ||
        emailToUpdate != null || descriptionToUpdate != null || addressToUpdate != null) 
        && !formIsValid) {
          ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct invalid fields.')),
      );
      setState(() { _updateInProgress = false; });
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
          if (state is BusinessProfileLoaded){
            final business = state.business;
            _businessNameController.text = business.business_name ?? '';
            _contactPersonFirstNameController.text = business.contact_person_first_name ?? '';
            _contactPersonLastNameController.text = business.contact_person_last_name ?? '';
            _phoneNumberController.text = business.phone_number ?? '';
            _emailController.text = business.email ?? '';
            _descriptionController.text = business.description ?? '';
            _addressController.text = business.address ?? '';

            _originalbusinessName = business.business_name;
            _originalcontactPersonFirstName = business.contact_person_first_name;
            _originalcontactPersonLastName = business.contact_person_last_name;
            _originalphoneNumber = business.phone_number;
            _originalemail = business.email;
            _originaldescription = business.description;
            _originaladdress = business.address;
            _currentavatarUrl = business.avatarUrl;
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
                            : (_currentavatarUrl != null && _currentavatarUrl!.isNotEmpty
                                ? NetworkImage(_currentavatarUrl!) 
                                : null) as ImageProvider<Object>?,
                                child: _pickedImage == null &&
                                (_currentavatarUrl == null || _currentavatarUrl!.isEmpty)
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
                      }
                    ),
                    TextFormField(
                      controller: _contactPersonLastNameController,
                      decoration: const InputDecoration(labelText: 'Contact Person Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      }
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
                      }
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
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          _updateInProgress ? null : () => _updateProfile(),
                        style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          _updateInProgress 
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