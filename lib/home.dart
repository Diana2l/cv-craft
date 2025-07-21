// ignore_for_file: prefer_const_constructors, unnecessary_import, prefer_final_fields, unused_field, unused_import, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:cv_craft/screens/education.dart';
import 'package:cv_craft/screens/experience.dart';
import 'package:cv_craft/screens/objectives.dart';
import 'package:cv_craft/screens/samples.dart';
import 'package:cv_craft/screens/skills.dart';
import 'package:cv_craft/screens/FAQ.dart';
import 'package:cv_craft/screens/templates.dart';
import 'package:cv_craft/screens/settings.dart';
import 'package:cv_craft/screens/profile.dart';
import 'package:cv_craft/auth/utility/globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  void initState() {
    super.initState();
    // Load the selected template when the home screen loads
    _loadSelectedTemplate();
  }

  Future<void> _loadSelectedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final templateId = prefs.getString('selected_template');
    
    if (mounted) {
      setState(() {
        _selectedTemplate = templateId;
      });
    }
  }

  String? _selectedTemplate;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedTemplate != null 
              ? '${_selectedTemplate![0].toUpperCase()}${_selectedTemplate!.substring(1)} CV' 
              : 'CV Craft',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: globals.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_selectedTemplate != null)
            IconButton(
              icon: Icon(Icons.swap_horiz, color: Colors.blue),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/templates');
              },
              tooltip: 'Change Template',
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings(onThemeChanged: (bool) {})),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedTemplate == null) ...[
              _buildWelcomeCard(),
              SizedBox(height: 24),
            ],
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'New CV',
                    onTap: () => Navigator.pushReplacementNamed(context, '/templates'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => Navigator.pushNamed(context, '/personal'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // CV Sections
            Text(
              'Build Your CV',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            _buildSectionCard(
              icon: Icons.person_outline,
              title: 'Personal Info',
              description: 'Add your personal details',
              onTap: () => Navigator.pushNamed(context, '/personal'),
            ),
            _buildSectionCard(
              icon: Icons.school_outlined,
              title: 'Education',
              description: 'Add your education history',
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Education(),
              ),
            ),
            _buildSectionCard(
              icon: Icons.work_outline,
              title: 'Experience',
              description: 'Add your work experience',
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Experience(),
              ),
            ),
            _buildSectionCard(
              icon: Icons.stars_outlined,
              title: 'Skills',
              description: 'Add your skills and expertise',
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => Skills(),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Templates Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Templates',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/templates'),
                  child: Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Template Previews
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTemplatePreview('Classic', 'assets/images/classic_template.png'),
                  SizedBox(width: 16),
                  _buildTemplatePreview('Modern', 'assets/images/modern_template.png'),
                  SizedBox(width: 16),
                  _buildTemplatePreview('Creative', 'assets/images/creative_template.png'),
                ],
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/templates'),
        label: Text('Create New CV'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ready to build your perfect CV?',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/templates'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Create New CV',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTemplatePreview(String title, String imagePath) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/templates'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/images/cv_preview_1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
}