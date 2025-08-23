import 'package:flutter/material.dart';
import 'package:cv_craft/screens/Build.dart';
import 'package:cv_craft/screens/report_screen.dart';
import 'package:cv_craft/models/cv_data.dart' as cv_data;

typedef BuildCVData = cv_data.CVData;

class CVEditorScreen extends StatefulWidget {
  final double fontSize;
  final double headerFontSize;
  final String fontFamily;
  final Color color;
  final String template;
  final String templateImage;
  final String objective;

  const CVEditorScreen({
    Key? key,
    required this.fontSize,
    required this.headerFontSize,
    required this.fontFamily,
    required this.color,
    required this.template,
    required this.templateImage,
    required this.objective,
  }) : super(key: key);

  @override
  _CVEditorScreenState createState() => _CVEditorScreenState();
}

class _CVEditorScreenState extends State<CVEditorScreen> {
  late BuildCVData _cvData;

  @override
  void initState() {
    super.initState();
    _cvData = cv_data.CVData();
  }

  void _updateCVData(cv_data.CVData newData) {
    if (!mounted) return;
    setState(() {
      _cvData = newData;
    });
  }

  void _goToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          cvData: _cvData,
          onUpdate: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Build Your CV',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: _goToReportScreen,
            tooltip: 'View Report',
          ),
        ],
      ),
      body: Build(
        fontSize: widget.fontSize,
        headerFontSize: widget.headerFontSize,
        fontFamily: widget.fontFamily,
        color: widget.color,
        template: widget.template,
        templateImage: widget.templateImage,
        objective: widget.objective,
        onCVDataUpdated: _updateCVData,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportScreen(
                cvData: _cvData,
                onUpdate: () {},
              ),
            ),
          );
        },
        icon: const Icon(Icons.analytics_outlined, color: Colors.white),
        label: const Text('View Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 4,
        hoverColor: Colors.teal[700],
        splashColor: Colors.teal[300],
      ),
    );
  }
}
