// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables, avoid_types_as_parameter_names, unused_import, non_constant_identifier_names, sort_child_properties_last, file_names

import 'package:flutter/material.dart';
import 'package:cv_craft/auth/login.dart';
import 'package:cv_craft/home.dart';
import 'package:cv_craft/screens/cv_editor_screen.dart';
import 'package:cv_craft/screens/about.dart';
import 'package:cv_craft/screens/profile.dart';
import 'package:cv_craft/screens/samples.dart';
import 'package:cv_craft/screens/settings.dart';
import 'package:cv_craft/screens/templates.dart';
import 'package:cv_craft/screens/Build.dart';

void main() {
  runApp(Userpage());
  
}

class Userpage extends StatefulWidget {
  @override
  _UserpageState createState() => _UserpageState(); 
}

class _UserpageState extends State<Userpage> {
  int _selectedIndex = 0; 
  final List<BottomNavigationBarItem> _bottomNavBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: 'Home',
      activeIcon: (Icon(Icons.home))
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.widgets_outlined),
      label: 'Templates',
      activeIcon: (Icon(Icons.widgets)
      
      )
      
    ),
   
    BottomNavigationBarItem(
      icon: Icon(Icons.create_outlined),
      label: 'Create',
      activeIcon: Icon(Icons.create)
    ),
    
    
  ];
  final List<Widget> _pages = [
    Home(),
    Templates(),
    CVEditorScreen(
      fontSize: 16,
      headerFontSize: 24,
      fontFamily: 'OpenSans',
      color: Colors.teal,
      objective: '',
      template: 'modern',
      templateImage: 'assets/images/Modern.png',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
         actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings(onThemeChanged: (bool ) {  },)),
                );
                },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> Profile())
                      );
                  }
      )]
        
      ),
      
        body:_pages[_selectedIndex], 
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.teal,
          items: _bottomNavBarItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          

        ),
       
     );
  }
}

