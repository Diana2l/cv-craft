import 'package:flutter/material.dart';

class Minimalist extends StatefulWidget {
  const Minimalist({super.key});

  @override
  State<Minimalist> createState() => _MinimalistState();
}

class _MinimalistState extends State<Minimalist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimalist UI'),
        backgroundColor: Colors.brown,
        ),
    );
  }
}