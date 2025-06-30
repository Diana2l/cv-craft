// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:cv_craft/screens/Build.dart';

class CompiledCVScreen extends StatelessWidget {
  final CVData cvData;
  final String objectives;
  final double fontSize;
  final double headerFontSize;
  final String fontFamily;
  final Color color;

  CompiledCVScreen({
    required this.cvData,
    required this.objectives,
    required this.fontSize,
    required this.headerFontSize,
    required this.fontFamily,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compiled CV', style: TextStyle(fontFamily: fontFamily , color: color , fontSize: fontSize)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _buildSection('Name', cvData.name, headerFontSize, fontFamily, color),
          _buildSection('Objectives', cvData.summary, fontSize, fontFamily, color),
          _buildSection('Experience', cvData.experience.join('\n'), fontSize, fontFamily, color),
          _buildSection('Education', cvData.education.join('\n'), fontSize, fontFamily, color),
          _buildSection('Skills', cvData.skills.join(', '), fontSize, fontFamily, color),
          
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, double textSize, String font, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: textSize,
              fontFamily: font,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
