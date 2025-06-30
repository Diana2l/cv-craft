import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        hintColor: Colors.teal,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, height: 1.5),
        ),
      ),
     
    );
  }
}

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          title: const Text('FAQ Page', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildExpansionTile(
              'Q: Should a resume have references and hobbies?',
              'Not really, but it’s good to have them in case they are needed.',
              _isExpanded1,
              (expanded) => setState(() {
                _isExpanded1 = expanded;
              }),
            ),
            const Divider(color: Colors.teal),
            _buildExpansionTile(
              'Q: Can I save my CV?',
              'To edit your CV, navigate to the CV editing page and make the necessary changes. Be sure to save your changes after editing.',
              _isExpanded2,
              (expanded) => setState(() {
                _isExpanded2 = expanded;
              }),
            ),
            const Divider(color: Colors.teal),
            _buildExpansionTile(
              'Q: How do I create a CV?',
              'To create a CV, go to the CV creation page and fill in your details in the required fields. You can also customize the layout and format of your CV.',
              _isExpanded3,
              (expanded) => setState(() {
                _isExpanded3 = expanded;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String question, String answer, bool isExpanded, Function(bool) onExpansionChanged) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: AnimatedRotation(
        turns: isExpanded ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.arrow_drop_down, color: Colors.teal),
      ),
      onExpansionChanged: onExpansionChanged,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(answer),
          ),
        ),
      ],
    );
  }
}
