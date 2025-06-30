// ignore_for_file: prefer_const_constructors, unnecessary_import, prefer_final_fields, unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:cv_craft/screens/education.dart';
import 'package:cv_craft/screens/experience.dart';
import 'package:cv_craft/screens/objectives.dart';
import 'package:cv_craft/screens/samples.dart';
import 'package:cv_craft/screens/skills.dart';
import 'package:cv_craft/screens/FAQ.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  body: Column(
   children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2 / 2,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Objectives();
                    },
                  );
                },
                child: _buildGridItem(Icons.list, 'Objectives'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/personal');
                },
                child: _buildGridItem(Icons.person, 'Personal'),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Education();
                    },
                  );
                },
                child: _buildGridItem(Icons.book_sharp, 'Education'),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Experience();
                    },
                  );
                },
                child: _buildGridItem(Icons.cases_rounded, 'Experience'),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Skills();
                    },
                  );
                },
                child: _buildGridItem(Icons.wallet_giftcard_sharp, 'Skills'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/faq');
                },
                child: _buildGridItem(Icons.question_answer_outlined, 'FAQ'),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child :GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/templates');
              },
             child: Text(
            'See All',
            style: TextStyle(
              fontSize: 18, 
              color: Colors.blue,
              decoration: TextDecoration.underline
              ),
          ),
            )
          ),
        
          _buildSlider(),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Colors.green, width: 2),
          top: BorderSide(color: Colors.green, width: 2),
          left: BorderSide(color: Colors.green, width: 2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Flexible(
      child: Stack(
        children: [
          PageView(
            children: [
              _buildSlide('Slide 1', 'assets/images/classic.png'),
              _buildSlide('Slide 2', 'assets/images/creative.png'),
              _buildSlide('Slide 3', 'assets/images/technical.png'),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildSlide(String text, String imagePath) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),
              Text(
                text,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}