// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cv_craft/models/ClassicPage.dart';
import 'package:cv_craft/models/creative.dart';
import 'package:cv_craft/models/minimalist.dart';
import 'package:cv_craft/models/modern.dart';
import 'package:cv_craft/models/technical.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cv_craft/home.dart';
import 'package:cv_craft/screens/Build.dart';

class Templates extends StatefulWidget {
  const Templates({Key? key}) : super(key: key);

  @override
  _TemplatesState createState() => _TemplatesState();
}

final List<String> templates = [
  'assets/images/Modern.png',
  'assets/images/creative.png',
  'assets/images/minimalist.png',
  'assets/images/classic.png',
  'assets/images/technical.png',
];

class _TemplatesState extends State<Templates> {
  int _selectedIndex = 1; // Templates tab is selected by default

  final List<Widget> _pages = [
    Home(),
    TemplatesContent(),
    Build(
      fontSize: 16, 
      fontFamily: 'OpenSans', 
      color: Colors.red, 
      headerFontSize: 24, 
      objective: '', 
      template: '', 
      templateImage: ''
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            label: 'Templates',
            activeIcon: Icon(Icons.widgets),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create_outlined),
            label: 'Create',
            activeIcon: Icon(Icons.create),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class TemplatesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick A Template!'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: templates.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return TemplateItem(
              templateImage: templates[index],
              templateName: templates[index].split('/').last.split('.').first,
            );
          },
        ),
      ),
    );
  }
}

class TemplateItem extends StatelessWidget {
  final String templateImage;
  final String templateName;

  const TemplateItem({Key? key, required this.templateImage, required this.templateName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              templateImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<int>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit this template'),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Download'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        if (templateName == 'Modern') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Modern(),
          ));
        } else if (templateName == 'creative') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Creative(),
          ));
        } 
        if (templateName == 'minimalist') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Minimalist(),
          ));
        } else if (templateName == 'classic') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ClassicPage(),
          ));
        } 
        if (templateName == 'technical') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Technical(),
          ));
        } 
        break;
        case 1:
        await downloadTemplate(templateImage);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template downloaded')),
        );
        break;
    }
  }
  Future<void> downloadTemplate(String url) async {
    try {
      final directory = await getApplictionDownloadsDirectory();
      final file = File('${directory.path}/template.zip');
      
      print('Downloaded templates are saved in : ${directory.path}');
      final filePath = '${directory.path}/${url.split('/').last}';
      await Dio().download(url, filePath);
    } catch (e) {
      print('Error downloading template:$e');
}
}

  getApplictionDownloadsDirectory() {}
  
  
}