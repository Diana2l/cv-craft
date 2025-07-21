// ignore_for_file: prefer_const_constructors, avoid_types_as_parameter_names, use_key_in_widget_constructors, library_private_types_in_public_api, unused_import, avoid_print

import 'package:cv_craft/screens/templates.dart';
import 'package:flutter/material.dart';
import 'package:cv_craft/screens/Build.dart';
import 'package:cv_craft/auth/login.dart';
import 'package:cv_craft/auth/register.dart';
import 'package:cv_craft/models/ProfileModel.dart';
import 'package:cv_craft/screens/education.dart';
import 'package:cv_craft/screens/experience.dart';
import 'package:cv_craft/screens/FAQ.dart';
import 'package:cv_craft/screens/objectives.dart';
import 'package:cv_craft/screens/profile.dart';
import 'package:cv_craft/screens/settings.dart';
import 'package:cv_craft/screens/skills.dart';
import 'package:cv_craft/screens/userpage.dart';
import 'package:cv_craft/screens/onboarding_screen.dart';
import 'package:cv_craft/screens/template_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'auth/utility/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState? of (BuildContext context)=> context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Builder',
      debugShowCheckedModeBanner: false,
      theme: changeTheme(globals.isDarkMode),
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return snapshot.data == true 
                ? const OnboardingScreen() 
                : const TemplateSelectionScreen();
          }
        },
      ),
      routes: {
        '/auth/register': (context) => Register(),
        '/auth/login': (context) => Login(),
        '/templates': (context) => TemplateSelectionScreen(),
        '/userpage': (context) => Userpage(),
        '/onboarding_screen': (context) => OnboardingScreen(),
        '/settings': (context) => Settings(onThemeChanged: (bool) {}),
        '/profile': (context) => Profile(),
        '/build': (context) => Build(fontSize: 16, headerFontSize: 24, fontFamily: 'OpenSans', color:Colors.red, objective: '', template: '', templateImage: '',),
        '/objective': (context) => Objectives(),
        '/personal': (context) => Profile(),
        '/education': (context) => Education(),
        '/experience': (context) => Experience(),
        '/skills': (context) => Skills(),
        '/faq': (context) => FAQ(),
      },
    );
  }
  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      // On first launch, show onboarding
      return true;
    }
    // After first launch, always go to template selection
    return false;
  }

  dynamic changeTheme(bool? value){
    print("-----------------------");
   setState((){
    globals.isDarkMode == true?ThemeData.dark():ThemeData.light();
      });
      if(globals.isDarkMode){return ThemeData.dark();} else {
        return ThemeData.light();
      }
      
}
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = globals.isDarkMode;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class ProfileModel with ChangeNotifier {
  String _username = 'John Doe';
  String _email = 'john.doe@example.com';
  String? _avatarPath;

  String get username => _username;
  String get email => _email;
  String? get avatarPath => _avatarPath;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setAvatarPath(String path) {
    _avatarPath = path;
    notifyListeners();
  }

  Future<void> loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'John Doe';
    _email = prefs.getString('email') ?? 'john.doe@example.com';
    _avatarPath = prefs.getString('avatarPath');
    notifyListeners();
  }

  Future<void> saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _username);
    prefs.setString('email', _email);
    if (_avatarPath != null) {
      prefs.setString('avatarPath', _avatarPath!);
    }
  }
}



 