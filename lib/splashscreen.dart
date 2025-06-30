// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, annotate_overrides

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cv_craft/auth/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
   void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login(),
        )
        );
        });
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/City.jpeg'),
            Text('CV Craft', style: TextStyle(fontSize: 20, color: Colors.blue),),
            CircularProgressIndicator(),
            ],
            ),
            ),
            );
    
  }
}

  @override
  Widget build(BuildContext context) {
    
    throw UnimplementedError();
  }

  
}