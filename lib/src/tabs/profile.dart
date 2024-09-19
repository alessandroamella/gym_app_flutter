import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym_app_flutter/src/models/user_dto.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  ApiService apiService = ApiService();
  UserDto? profileData;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _loadUserProfile() async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token != null) {
      try {
        var data = await apiService.getUserProfile(token);
        setState(() {
          profileData = data;
          _usernameController.text = data.username;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token available')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (profileData == null) {
      debugPrint('Profile data is null');
      return;
    } else if (_formKey.currentState!.validate()) {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (token != null) {
        try {
          var updatedUser = await apiService.updateUserProfile(
            token,
            profileData!.fiscalCode,
            username: _usernameController.text,
            profilePic: File(_image!.path),
          );

          // update token
          Provider.of<UserProvider>(context, listen: false)
              .setToken(updatedUser.token);

          setState(() {
            profileData = updatedUser.user;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $error')),
          );
        }
      }
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _getImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (profileData!.profilePic != null
                                ? NetworkImage(profileData!.profilePic!.url)
                                : null) as ImageProvider?,
                        child: _image == null && profileData!.profilePic == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Fiscal Code'),
                      subtitle: Text(profileData!.fiscalCode),
                    ),
                    ListTile(
                      title: const Text('Gender'),
                      subtitle: Text(profileData!.gender),
                    ),
                    ListTile(
                      title: const Text('Birthdate'),
                      subtitle: Text(profileData!.birthdate),
                    ),
                    ListTile(
                      title: const Text('Role'),
                      subtitle: Text(profileData!.role),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
