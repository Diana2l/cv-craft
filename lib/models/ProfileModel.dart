// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class ProfileModel with ChangeNotifier {
  String _name = '';
  String _email = '';
  String? _selectedTemplate;
  Map<String, dynamic> _cvData = {
    'personalInfo': {},
    'education': [],
    'experience': [],
    'skills': [],
  };
  File? _avatar;

  String get name => _name;
  String get email => _email;
  String? get selectedTemplate => _selectedTemplate;
  Map<String, dynamic> get cvData => _cvData;
  File? get avatar => _avatar;

  set email(String value) {
    _email = value;
    _cvData['personalInfo']['email'] = value;
    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateSelectedTemplate(String? newTemplate) {
    _selectedTemplate = newTemplate;
    notifyListeners();
  }

  void updateCvData(Map<String, dynamic> newCvData) {
    _cvData = newCvData;
    notifyListeners();
  }

  void updateAvatar(File newAvatar) {
    _avatar = newAvatar;
    notifyListeners();
  }

  Future<void> setSelectedTemplate(String templateId) async {}
}