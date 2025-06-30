// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Technical extends StatefulWidget {
  const Technical({super.key});

  @override
  State<Technical> createState() => _TechnicalState();
}

class _TechnicalState extends State<Technical> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Technical'),
        backgroundColor: Colors.brown,
        ),
    );
  }
}