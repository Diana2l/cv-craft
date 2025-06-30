// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, prefer_typing_uninitialized_variables, avoid_types_as_parameter_names, unused_import, non_constant_identifier_names, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cv_craft/auth/login.dart';
import 'package:cv_craft/home.dart';
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
  final List<Widget> _pages=[
    Home(),
      Templates(),
      Build(fontSize: 16, fontFamily:'OpenSans', color: Colors.red, headerFontSize: 24, objective: '', template: '', templateImage: '',),
      
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
        title: Text('CV Builder'),
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
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Welcome!'),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
              onTap: () {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Userpage()));
              },
            ),
         

            ListTile(
              title: Text("Settings"),
              leading: Icon(Icons.settings),
              onTap: () {
                 Navigator.of(context).push(MaterialPageRoute(builder:(context) => Settings(onThemeChanged: (bool ) {  },)));
              },
            ),
            ListTile(
              title: Text("CV+CoverLetter"),
              leading: Icon(Icons.type_specimen),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Samples()));
              },
            ),
            ListTile(
              title: Text("About Us"),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>About()));
              },
            ),
             ListTile(
              title: Text("Log out"),
              leading: Icon(Icons.logout),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Login()));
              },
            ),
          ],
  ),
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

