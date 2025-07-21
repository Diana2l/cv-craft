import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cv_craft/models/ProfileModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({Key? key}) : super(key: key);

  @override
  _TemplateSelectionScreenState createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final List<Map<String, dynamic>> templates = [
    {
      'id': 'ats_professional',
      'name': 'Professional ATS',
      'preview': 'assets/images/ats_professional.png',
      'description': 'Optimized for ATS with clean formatting',
      'color': Colors.blueGrey[700],
      'category': 'ATS',
    },
    {
      'id': 'ats_simple',
      'name': 'Simple ATS',
      'preview': 'assets/images/ats_simple.png',
      'description': 'Minimalist design for maximum ATS compatibility',
      'color': Colors.teal[700],
      'category': 'ATS',
    },
    {
      'id': 'classic',
      'name': 'Classic',
      'preview': 'assets/images/classic_preview.png',
      'description': 'Professional and clean design',
      'color': Colors.blue,
      'category': 'Standard',
    },
    {
      'id': 'modern',
      'name': 'Modern',
      'preview': 'assets/images/modern_preview.png',
      'description': 'Sleek and contemporary layout',
      'color': Colors.purple,
      'category': 'Standard',
    },
  ];

  String? selectedTemplateId;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }

  Future<void> _loadSelectedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTemplate = prefs.getString('selected_template');
    if (savedTemplate != null && mounted) {
      setState(() {
        selectedTemplateId = savedTemplate;
        final index = templates.indexWhere((t) => t['id'] == savedTemplate);
        if (index != -1) {
          _currentPage = index;
          _pageController.jumpToPage(index);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group templates by category
    final Map<String, List<Map<String, dynamic>>> categorizedTemplates = {};
    for (var template in templates) {
      final category = template['category'] as String;
      if (!categorizedTemplates.containsKey(category)) {
        categorizedTemplates[category] = [];
      }
      categorizedTemplates[category]!.add(template);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Template', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATS Tips Banner
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For best ATS results, use our ATS-optimized templates and include relevant keywords from the job description.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Template Categories
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: templates.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  selectedTemplateId = templates[index]['id'];
                });
              },
              itemBuilder: (context, index) {
                return _buildTemplateCard(templates[index]);
              },
            ),
          ),
          // Page indicator
          Container(
            height: 20,
            margin: EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[300],
                  ),
                );
              },
            ),
          ),
          // Select button
          Container(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: selectedTemplateId != null
                  ? () => _onTemplateSelected(selectedTemplateId!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                selectedTemplateId == templates[_currentPage]['id'] 
                    ? 'Selected' 
                    : 'Select Template',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final isSelected = selectedTemplateId == template['id'];
    
    return GestureDetector(
      onTap: () {
        final index = templates.indexWhere((t) => t['id'] == template['id']);
        if (index != -1) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isSelected
                  ? BorderSide(color: template['color'], width: 3)
                  : BorderSide.none,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: template['color'].withOpacity(0.1),
                      image: DecorationImage(
                        image: AssetImage(template['preview']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        template['description'],
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTemplateSelected(String templateId) async {
    // Save the selected template
    final profileModel = Provider.of<ProfileModel>(context, listen: false);
    await profileModel.setSelectedTemplate(templateId);
    
    // Save template preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_template', templateId);
    
    // Navigate to home screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
