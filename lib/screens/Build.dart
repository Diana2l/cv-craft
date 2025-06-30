// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:cv_craft/screens/compiled_cv.dart';

class CVData {
  String name = '';
  String summary = '';
  String email = '';
  String phone = '';
  String linkedin = '';
  List<String> experience = [];
  List<String> education = [];
  List<String> skills = [];
  List<String> projects = [];
  List<String> achievements = [];
  List<String> references = [];
}

class Build extends StatefulWidget {
  final double fontSize;
  final double headerFontSize;
  final String fontFamily;
  final Color color;

  Build({
    required this.fontSize,
    required this.headerFontSize,
    required this.fontFamily,
    required this.color, required String objective, required String template, required String templateImage,
  });

  @override
  _BuildState createState() => _BuildState();
}

class _BuildState extends State<Build> {
  final _cvData = CVData();
  final _nameController = TextEditingController();
  final _summaryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60),
              TextFormField(
                controller: _nameController,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => _cvData.name = value,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.color,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _summaryController,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Objectives'),
                onChanged: (value) => _cvData.summary = value,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.color,
                ),
              ),
              TextFormField(
                controller: _experienceController,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Experience'),
                onChanged: (value) => _cvData.experience = value.split('\n'),
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.color,
                ),
              ),
              TextFormField(
                controller: _educationController,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Education'),
                onChanged: (value) => _cvData.education = value.split('\n'),
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.color,
                ),
              ),
              TextFormField(
                controller: _skillsController,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Skills'),
                onChanged: (value) => _cvData.skills = value.split(', '),
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                  color: widget.color,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompiledCVScreen(
                        cvData: _cvData,
                        objectives: '', 
                        fontSize: widget.fontSize,
                        headerFontSize: widget.headerFontSize,
                        fontFamily: widget.fontFamily,
                        color: widget.color,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Compile CV',
                  style: TextStyle(
                    fontFamily: widget.fontFamily,),
                ),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
