// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';


class ProfileModel with ChangeNotifier {
  String _username = 'John Doe';
  String _email = 'john.doe@example.com';
  File? _avatar;

  String get username => _username;
  String get email => _email;
  File? get avatar => _avatar;

  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updateAvatar(File newAvatar) {
    _avatar = newAvatar;
    notifyListeners();
  }
}