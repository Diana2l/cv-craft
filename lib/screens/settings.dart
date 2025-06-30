// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_final_fields, unused_field, avoid_print

import 'package:flutter/material.dart';
import 'package:cv_craft/main.dart';
import 'package:cv_craft/screens/font_style.dart';
import 'package:cv_craft/auth/utility/globals.dart' as globals;

class Settings extends StatefulWidget {
  const Settings({super.key, required this.onThemeChanged});

  final Function(bool) onThemeChanged;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notificationsSwitchValue = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    trailing: Switch(
                      value: globals.isDarkMode,
                      onChanged: (value) {
                        print("====> $value"); 
                        setState(() {
                          globals.isDarkMode = value;
                          MyApp.of(context)?.changeTheme(value); 
                        });
                        widget.onThemeChanged(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text('Text Style'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FontStylePage(onApply: (String fontSize, String headerFontSize, String fontFamily, Color selectedColor) {  },),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
