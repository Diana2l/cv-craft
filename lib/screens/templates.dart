import 'package:cv_craft/screens/cv_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


final List<String> templates = [
  'assets/images/Modern.png',
  'assets/images/creative.png',
  'assets/images/minimalist.png',
  'assets/images/classic.png',
  'assets/images/technical.png',
];

class Templates extends StatefulWidget {
  @override
  _Templates createState() => _Templates();
}

class _Templates extends State<Templates> {
  int currentIndex = 0;

  Future<void> _selectTemplate(String templatePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_template', templatePath);
    
    // Extract template name from path (e.g., 'Modern' from 'assets/images/Modern.png')
    final templateName = templatePath
        .split('/')
        .last
        .split('.')
        .first
        .toLowerCase();

    // Navigate to CV Editor with selected template
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CVEditorScreen(
          fontSize: 16,
          headerFontSize: 24,
          fontFamily: 'OpenSans',
          color: Colors.teal,
          objective: '',
          template: templateName,
          templateImage: templatePath,
        ),
      ),
    );
  }

  void _nextTemplate() {
    setState(() {
      currentIndex = (currentIndex + 1) % templates.length;
    });
  }

  void _previousTemplate() {
    setState(() {
      currentIndex = (currentIndex - 1 + templates.length) % templates.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String template = templates[currentIndex];
    final String templateName = template.split('/').last.split('.').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Template'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousTemplate,
                icon: const Icon(Icons.arrow_left, size: 40),
              ),
              Container(
                width: 250,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.asset(template, fit: BoxFit.contain),
              ),
              IconButton(
                onPressed: _nextTemplate,
                icon: const Icon(Icons.arrow_right, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(templateName, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectTemplate(template),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Use This Template'),
          ),
        ],
      ),
    );
  }
}
