// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:cv_craft/screens/compiled_cv.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the CVData from models
import 'package:cv_craft/models/cv_data.dart' as cv_data;

// Alias for backward compatibility
typedef CVData = cv_data.CVData;

class Build extends StatefulWidget {
  final double fontSize;
  final double headerFontSize;
  final String fontFamily;
  final Color color;
  final String template;
  final String templateImage;
  final Function(cv_data.CVData)? onCVDataUpdated; // Callback for CV data updates

  const Build({
    Key? key,
    required this.fontSize,
    required this.headerFontSize,
    required this.fontFamily,
    required this.color,
    required this.objective,
    required this.template,
    required this.templateImage,
    this.onCVDataUpdated,
  }) : super(key: key);

  final String objective;

  @override
  _BuildState createState() => _BuildState();
}

class _BuildState extends State<Build> {
  final _formKey = GlobalKey<FormState>();
  final _cvData = cv_data.CVData();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _certificationsController = TextEditingController();

  int _currentStep = 0;
  final List<Step> _steps = [];

  @override
  void initState() {
    super.initState();
    _initSteps();
  }

  void _initSteps() {
    _steps.addAll([
      _buildPersonalInfoStep(),
      _buildSummaryStep(),
      _buildExperienceStep(),
      _buildEducationStep(),
      _buildSkillsStep(),
      _buildProjectsStep(),
      _buildAdditionalInfoStep(),
    ]);
  }

  Step _buildPersonalInfoStep() {
    return Step(
      title: Text('Personal Info', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            onChanged: (value) {
              setState(() {
                _cvData.name = value;
                _updateCVData();
              });
            },
            validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() {
                _cvData.email = value;
                _updateCVData();
              });
            },
            validator: (value) => !value!.contains('@') ? 'Enter a valid email' : null,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                _cvData.phone = value;
                _updateCVData();
              });
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _linkedinController,
            label: 'LinkedIn (optional)',
            icon: Icons.link_outlined,
            onChanged: (value) {
              setState(() {
                _cvData.linkedin = value;
                _updateCVData();
              });
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            onChanged: (value) {
              setState(() {
                _cvData.address = value;
                _updateCVData();
              });
            },
          ),
        ],
      ),
    );
  }

  Step _buildSummaryStep() {
    return Step(
      title: Text('Professional Summary', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: _buildTextField(
        controller: _summaryController,
        label: 'Write a brief summary about yourself',
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            _cvData.summary = value;
            _updateCVData();
          });
        },
      ),
    );
  }

  Step _buildExperienceStep() {
    return Step(
      title: Text('Work Experience', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: _buildTextField(
        controller: _experienceController,
        label: 'List your work experience (one per line)',
        hint: 'e.g., Job Title at Company (Year - Year)\n- Responsibility 1\n- Responsibility 2',
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            _cvData.experience = value.split('\n');
            _updateCVData();
          });
        },
      ),
    );
  }

  Step _buildEducationStep() {
    return Step(
      title: Text('Education', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: _buildTextField(
        controller: _educationController,
        label: 'List your education (one per line)',
        hint: 'e.g., Degree, University, Year',
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            _cvData.education = value.split('\n');
            _updateCVData();
          });
        },
      ),
    );
  }

  Step _buildSkillsStep() {
    return Step(
      title: Text('Skills', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: _buildTextField(
        controller: _skillsController,
        label: 'List your skills (comma separated)',
        hint: 'e.g., Project Management, Team Leadership, JavaScript',
        onChanged: (value) {
          setState(() {
            _cvData.skills = value.split(',').map((e) => e.trim()).toList();
            _updateCVData();
          });
        },
      ),
    );
  }

  Step _buildProjectsStep() {
    return Step(
      title: Text('Projects', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: _buildTextField(
        controller: _projectsController,
        label: 'List your projects (one per line)',
        hint: 'e.g., Project Name - Description (Year)\n- Key achievement 1\n- Key achievement 2',
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            _cvData.projects = value.split('\n');
            _updateCVData();
          });
        },
      ),
    );
  }

  Step _buildAdditionalInfoStep() {
    return Step(
      title: Text('Additional Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      content: Column(
        children: [
          _buildTextField(
            controller: _languagesController,
            label: 'Languages (comma separated)',
            hint: 'e.g., English (Fluent), Spanish (Intermediate)',
            onChanged: (value) {
              setState(() {
                _cvData.languages = value.split(',').map((e) => e.trim()).toList();
                _updateCVData();
              });
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _certificationsController,
            label: 'Certifications (one per line)',
            hint: 'e.g., Project Management Professional (PMP), 2020',
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _cvData.certifications = value.split('\n');
                _updateCVData();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // Track the last update time to prevent too frequent updates
  DateTime? _lastUpdateTime;
  static const Duration _minUpdateInterval = Duration(milliseconds: 500);

  void _updateCVData() {
    final now = DateTime.now();
    // Skip if we've updated too recently
    if (_lastUpdateTime != null && now.difference(_lastUpdateTime!) < _minUpdateInterval) {
      return;
    }
    _lastUpdateTime = now;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Update CV data with all fields
      _cvData.summary = _summaryController.text;
      _cvData.email = _emailController.text;
      _cvData.phone = _phoneController.text;
      _cvData.linkedin = _linkedinController.text;
      _cvData.address = _addressController.text;
      _cvData.experience = _experienceController.text.split('\n');
      _cvData.education = _educationController.text.split('\n');
      _cvData.skills = _skillsController.text.split(',').map((e) => e.trim()).toList();
      _cvData.projects = _projectsController.text.split('\n');
      _cvData.languages = _languagesController.text.split(',').map((e) => e.trim()).toList();
      _cvData.certifications = _certificationsController.text.split('\n');
      
      // Notify parent widget about the CV data update
      if (widget.onCVDataUpdated != null) {
        widget.onCVDataUpdated!(_cvData);
      }
    }
  }

  void _submitForm() {
    _updateCVData();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompiledCVScreen(
          cvData: _cvData,
          objectives: _summaryController.text,
          fontSize: widget.fontSize,
          headerFontSize: widget.headerFontSize,
          fontFamily: widget.fontFamily,
          color: widget.color,
          template: widget.template.toLowerCase(),
          templateImage: widget.templateImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: _steps,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  if (_currentStep != 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('BACK', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1 ? 'PREVIEW CV' : 'NEXT',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
