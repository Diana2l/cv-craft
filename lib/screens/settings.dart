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
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedFileFormat = 'PDF';

  final List<String> _languages = ['English', 'Swahili', 'French'];
  final List<String> _formats = ['PDF', 'DOCX'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('General'),
            _buildSwitchTile(
              'Dark Theme',
              globals.isDarkMode,
              (value) {
                setState(() {
                  globals.isDarkMode = value;
                  MyApp.of(context)?.changeTheme(value);
                });
                widget.onThemeChanged(value);
              },
            ),
            ListTile(
              title: const Text('Text Style'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FontStylePage(
                      onApply: (String fontSize, String headerFontSize,
                          String fontFamily, Color selectedColor) {
                        // Implement your styling application logic
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Preferences'),
            _buildDropdownTile(
              title: 'Language',
              currentValue: _selectedLanguage,
              items: _languages,
              onChanged: (value) => setState(() => _selectedLanguage = value),
            ),
            _buildDropdownTile(
              title: 'Default File Format',
              currentValue: _selectedFileFormat,
              items: _formats,
              onChanged: (value) => setState(() => _selectedFileFormat = value),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Data & Notifications'),
            _buildSwitchTile(
              'Enable Notifications',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Auto Backup CVs',
              _autoBackupEnabled,
              (value) => setState(() => _autoBackupEnabled = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String currentValue,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: currentValue,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}