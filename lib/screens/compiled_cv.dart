// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, must_be_immutable, library_private_types_in_public_api, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cv_craft/screens/Build.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CompiledCVScreen extends StatelessWidget {
  final CVData cvData;
  final String objectives;
  final double fontSize;
  final double headerFontSize;
  final String fontFamily;
  final Color color;
  final String template;
  final String templateImage;

  const CompiledCVScreen({
    required this.cvData,
    required this.objectives,
    required this.fontSize,
    required this.headerFontSize,
    required this.fontFamily,
    required this.color,
    this.template = 'modern',
    this.templateImage = '',
  });

  Future<void> _generateAndSavePdf() async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      // Create a PDF document
      final pdf = pw.Document();
      
      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, child: pw.Text(cvData.name ?? 'CV', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 10),
                if (cvData.email?.isNotEmpty == true) pw.Text('Email: ${cvData.email}'),
                if (cvData.phone?.isNotEmpty == true) pw.Text('Phone: ${cvData.phone}'),
                if (cvData.address?.isNotEmpty == true) pw.Text('Address: ${cvData.address}'),
                
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Objective')),
                pw.Text(objectives.isNotEmpty ? objectives : 'No objective provided'),
                
                if (cvData.education?.isNotEmpty == true) ...[
                  pw.SizedBox(height: 20),
                  pw.Header(level: 1, child: pw.Text('Education')),
                  ...cvData.education!.map((edu) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(edu['degree'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${edu['institution'] ?? ''} - ${edu['year'] ?? ''}'),
                      if (edu['description']?.isNotEmpty == true) pw.Text(edu['description'] ?? ''),
                      pw.SizedBox(height: 5),
                    ],
                  )).toList(),
                ],
                
                if (cvData.experience?.isNotEmpty == true) ...[
                  pw.SizedBox(height: 20),
                  pw.Header(level: 1, child: pw.Text('Experience')),
                  ...cvData.experience!.map((exp) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(exp['title'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('${exp['company'] ?? ''} - ${exp['duration'] ?? ''}'),
                      if (exp['description']?.isNotEmpty == true) pw.Text(exp['description'] ?? ''),
                      pw.SizedBox(height: 5),
                    ],
                  )).toList(),
                ],
                
                if (cvData.skills?.isNotEmpty == true) ...[
                  pw.SizedBox(height: 20),
                  pw.Header(level: 1, child: pw.Text('Skills')),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: cvData.skills!.map((skill) => pw.Chip(
                      label: pw.Text(skill),
                    )).toList(),
                  ),
                ],
              ],
            );
          },
        ),
      );

      // Get the application documents directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/cv_${DateTime.now().millisecondsSinceEpoch}.pdf');
      
      // Save the PDF to a file
      await file.writeAsBytes(await pdf.save());
      
      // Share the file
      await Share.shareFiles([file.path], text: 'My CV');
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CV Preview', style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        )),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Generating PDF...')),
                );
                
                final filePath = await _generateAndSavePdf();
                
                if (!context.mounted) return;
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('CV saved successfully!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        // Open the file with the default app
                        // You can use the 'open_file' package for better file handling
                        // For now, we'll just show a message
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Opening file...')),
                        );
                      },
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to generate PDF: $e'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _buildTemplate(),
    );
  }

  Widget _buildTemplate() {
    switch (template.toLowerCase()) {
      case 'ats_professional':
        return _buildAtsProfessionalTemplate();
      case 'ats_simple':
        return _buildAtsSimpleTemplate();
      case 'modern':
        return _buildModernTemplate();
      case 'classic':
        return _buildClassicTemplate();
      default:
        return _buildAtsProfessionalTemplate(); // Default to ATS Professional
    }
  }

  // Placeholder for ATS Professional Template
  Widget _buildAtsProfessionalTemplate() {
    return Center(
      child: Text(
        'ATS Professional Template (to be implemented)',
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.teal),
      ),
    );
  }

  // Placeholder for ATS Simple Template
  Widget _buildAtsSimpleTemplate() {
    return Center(
      child: Text(
        'ATS Simple Template (to be implemented)',
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.teal),
      ),
    );
  }

  Widget _buildModernTemplate() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and contact info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cvData.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 8),
                if (cvData.title.isNotEmpty) Text(
                  cvData.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (cvData.email.isNotEmpty) _buildContactInfo(Icons.email, cvData.email),
                    if (cvData.phone.isNotEmpty) _buildContactInfo(Icons.phone, cvData.phone),
                    if (cvData.address.isNotEmpty) _buildContactInfo(Icons.location_on, cvData.address),
                    if (cvData.linkedin.isNotEmpty) _buildContactInfo(Icons.link, cvData.linkedin),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Professional Summary
          if (cvData.summary.isNotEmpty) _buildSection(
            'PROFESSIONAL SUMMARY',
            cvData.summary,
            Icons.person_outline,
          ),
          
          // Work Experience
          if (cvData.experience.isNotEmpty) _buildSection(
            'WORK EXPERIENCE',
            cvData.experience.join('\n\n'),
            Icons.work_outline,
          ),
          
          // Education
          if (cvData.education.isNotEmpty) _buildSection(
            'EDUCATION',
            cvData.education.join('\n\n'),
            Icons.school_outlined,
          ),
          
          // Skills
          if (cvData.skills.isNotEmpty) _buildSection(
            'SKILLS',
            cvData.skills.join(', '),
            Icons.star_outline,
          ),
          
          // Projects
          if (cvData.projects.isNotEmpty) _buildSection(
            'PROJECTS',
            cvData.projects.join('\n\n'),
            Icons.folder_open_outlined,
          ),
          
          // Certifications
          if (cvData.certifications.isNotEmpty) _buildSection(
            'CERTIFICATIONS',
            cvData.certifications.join('\n'),
            Icons.verified_outlined,
          ),
          
          // Languages
          if (cvData.languages.isNotEmpty) _buildSection(
            'LANGUAGES',
            cvData.languages.join(', '),
            Icons.language_outlined,
          ),
        ],
      ),
    );
  }
  
  Widget _buildClassicTemplate() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Title
          Center(
            child: Column(
              children: [
                Text(
                  cvData.name.toUpperCase(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (cvData.title.isNotEmpty) Text(
                  cvData.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                Divider(
                  height: 40,
                  thickness: 2,
                  color: Colors.grey.shade300,
                  indent: 100,
                  endIndent: 100,
                ),
              ],
            ),
          ),
          
          // Contact Info
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 16,
              children: [
                if (cvData.email.isNotEmpty) _buildContactInfo(Icons.email, cvData.email, isClassic: true),
                if (cvData.phone.isNotEmpty) _buildContactInfo(Icons.phone, cvData.phone, isClassic: true),
                if (cvData.address.isNotEmpty) _buildContactInfo(Icons.location_on, cvData.address, isClassic: true),
                if (cvData.linkedin.isNotEmpty) _buildContactInfo(Icons.link, cvData.linkedin, isClassic: true),
              ],
            ),
          ),
          
          // Content Sections
          if (cvData.summary.isNotEmpty) _buildClassicSection('SUMMARY', cvData.summary),
          if (cvData.experience.isNotEmpty) _buildClassicSection('EXPERIENCE', cvData.experience.join('\n\n')),
          if (cvData.education.isNotEmpty) _buildClassicSection('EDUCATION', cvData.education.join('\n\n')),
          if (cvData.skills.isNotEmpty) _buildClassicSection('SKILLS', cvData.skills.join(', ')),
          if (cvData.projects.isNotEmpty) _buildClassicSection('PROJECTS', cvData.projects.join('\n\n')),
          if (cvData.certifications.isNotEmpty) _buildClassicSection('CERTIFICATIONS', cvData.certifications.join('\n')),
          if (cvData.languages.isNotEmpty) _buildClassicSection('LANGUAGES', cvData.languages.join(', ')),
        ],
      ),
    );
  }
  
  
  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal, size: 24),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildClassicSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Divider(color: Colors.grey.shade400, thickness: 1),
        SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.openSans(
            fontSize: 14,
            height: 1.6,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
  
  
  Widget _buildContactInfo(IconData icon, String text, {bool isLight = false, bool isClassic = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: isLight ? Colors.white : Colors.teal),
        SizedBox(width: 4),
        Text(
          text,
          style: isClassic 
              ? GoogleFonts.openSans(fontSize: 12, color: Colors.grey.shade700)
              : GoogleFonts.poppins(
                  fontSize: 12,
                  color: isLight ? Colors.white : Colors.grey.shade800,
                ),
        ),
      ],
    );
  }
}
