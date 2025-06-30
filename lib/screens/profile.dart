// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, unused_field, unused_import

import 'dart:io';
import 'package:cv_craft/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _editMode = false;
  String _welcomeMessage = 'Welcome, John Doe';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await Provider.of<ProfileModel>(context, listen: false).loadProfileData();
    final profile = Provider.of<ProfileModel>(context, listen: false);
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    setState(() {
      _welcomeMessage = 'Welcome, ${profile.username}';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final profile = Provider.of<ProfileModel>(context, listen: false);
      profile.setUsername(_usernameController.text);
      profile.setEmail(_emailController.text);
      await profile.saveProfileData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _editMode = false;
        _welcomeMessage = 'Welcome, ${_usernameController.text}';
      });
    }
  }

  void _changeAvatar() async {
    final profile = Provider.of<ProfileModel>(context, listen: false);
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      profile.setAvatarPath(image.path);
      await profile.saveProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileModel>(
      builder: (context, profile, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_welcomeMessage),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _editMode = !_editMode;
                  });
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _changeAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profile.avatarPath != null
                          ? FileImage(File(profile.avatarPath!))
                          : null,
                      child: profile.avatarPath == null
                          ? Icon(Icons.camera_alt_outlined, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    enabled: _editMode,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    enabled: _editMode,
                  ),
                  const SizedBox(height: 20),
                  _editMode
                      ? ElevatedButton(
                          onPressed: _saveChanges,
                          child: const Text('Save Changes'),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
