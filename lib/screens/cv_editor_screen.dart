import 'package:flutter/material.dart';
import 'package:cv_craft/screens/Build.dart';
import 'package:cv_craft/screens/report_screen.dart';
import 'package:cv_craft/models/cv_data.dart' as cv_data;

// Import Build's CVData to access the type
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
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

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

  void _toggleView() {
    final newPage = _currentPage == 0 ? 1 : 0;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPage == 0 ? 'Build Your CV' : 'CV Completion Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _currentPage == 0 ? Icons.analytics_outlined : Icons.edit_outlined,
              color: Colors.white,
            ),
            onPressed: _toggleView,
            tooltip: _currentPage == 0 ? 'View Report' : 'Back to Editor',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          // Build Screen
          Build(
            fontSize: widget.fontSize,
            headerFontSize: widget.headerFontSize,
            fontFamily: widget.fontFamily,
            color: widget.color,
            template: widget.template,
            templateImage: widget.templateImage,
            objective: widget.objective,
            onCVDataUpdated: _updateCVData,
          ),
          // Report Screen
          ReportScreen(
            cvData: _cvData,
            onUpdate: () {
              // This will be called when the user taps the refresh button on the report screen
              // No need to manually trigger update as it's handled by the Build widget
            },
          ),
        ],
      ),
      floatingActionButton: _currentPage == 0
          ? FloatingActionButton.extended(
              onPressed: _toggleView,
              icon: Icon(Icons.analytics_outlined),
              label: Text('View Report'),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
