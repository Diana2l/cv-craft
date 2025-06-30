// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unused_import, prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api

import 'package:cv_craft/auth/utility/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cv_craft/screens/Build.dart';

class FontStylePage extends StatefulWidget {
  final void Function(String fontSize, String headerFontSize, String fontFamily, Color selectedColor) onApply;
  FontStylePage({required this.onApply});

  @override
  _FontStylePageState createState() => _FontStylePageState();
}

class _FontStylePageState extends State<FontStylePage> {
  static const _fontSizeOptions = ['16 px', '24 px', '32 px'];
  static const _fontFamilyOptions = ['OpenSans', 'Times New Roman', 'Courier New', 'Roboto', 'Lobster'];

  String _fontSize = '16 px';
  String _headerFontSize = '24 px';
  String _fontFamily = 'OpenSans'; 
  Color _selectedColor = Colors.red;

  final List<Color> _colorOptions = [Colors.red, Colors.blue, Colors.green, Colors.black, Colors.purple ,Colors.teal, ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getString('fontSize') ?? '16 px';
      _headerFontSize = prefs.getString('headerFontSize') ?? '24 px';
      _fontFamily = prefs.getString('fontFamily') ?? 'OpenSans';
      _selectedColor = Color(prefs.getInt('selectedColor') ?? Colors.red.value);
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', _fontSize);
    await prefs.setString('headerFontSize', _headerFontSize);
    await prefs.setString('fontFamily', _fontFamily);
    await prefs.setInt('selectedColor', _selectedColor.value);
  }

  double _parseFontSize(String fontSize) {
    return double.parse(fontSize.split(' ')[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Style', style: TextStyle(fontFamily: _fontFamily)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDropdown(
            label: 'Font Size',
            value: _fontSize,
            options: _fontSizeOptions,
            onChanged: (newValue) {
              setState(() {
                _fontSize = newValue!;
              });
            },
          ),
          _buildDropdown(
            label: 'Header Font Size',
            value: _headerFontSize,
            options: _fontSizeOptions,
            onChanged: (newValue) {
              setState(() {
                _headerFontSize = newValue!;
              });
            },
          ),
          _buildDropdown(
            label: 'Font Family',
            value: _fontFamily,
            options: _fontFamilyOptions,
            onChanged: (newValue) {
              setState(() {
                _fontFamily = newValue!;
              });
            },
          ),
          SizedBox(height: 16),
          Text('Color', style: TextStyle(fontSize: 18, fontFamily: _fontFamily)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _colorOptions.map((color) => buildColorCircle(color)).toList(),
          ),
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fontSize = '16 px';
                    _headerFontSize = '24 px';
                    _fontFamily = 'OpenSans';
                    _selectedColor = Colors.red;
                  });
                  _savePreferences();
                },
                child: Text('Cancel', style: TextStyle(fontFamily: _fontFamily)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
              ElevatedButton(
                onPressed: () {
                  _savePreferences();
                  widget.onApply(_fontSize, _headerFontSize, _fontFamily, _selectedColor);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Build(
                      fontSize: _parseFontSize(_fontSize),
                      headerFontSize: _parseFontSize(_headerFontSize),
                      fontFamily:  _fontFamily,
                      color: _selectedColor, objective: '', template: '', templateImage: '',

                    )),
                  );
                },
                child: Text('Apply', style: TextStyle(fontFamily: _fontFamily)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontFamily: _fontFamily),
          ),
          DropdownButton<String>(
            value: value,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontFamily: _fontFamily),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 16,
          child: _selectedColor == color ? Icon(Icons.check, color: Colors.white) : null,
        ),
      ),
    );
  }
}
