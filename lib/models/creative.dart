// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Creative(),
    );
  }
}

class Creative extends StatefulWidget {
  const Creative({super.key});

  @override
  _CreativeState createState() => _CreativeState();
}

class _CreativeState extends State<Creative> {
  final TextEditingController nameController = TextEditingController(text: "EMMA WOODHOUSE");
  final TextEditingController titleController = TextEditingController(text: "Administration Manager");
  final TextEditingController aboutmeController = TextEditingController(text: "Leadership a marketing team\nto develop and implement\n creative and unique strategies to\n drive customer interest through\n multiple media channels");
  final TextEditingController experienceController1 = TextEditingController(text: "2019 - Present | Landscape Architect\nFreelance\nDesigning efficient and beautiful outdoor garden spaces for clients. Altered designs in accordance with client needs and requirements. Overseeing the development of garden design projects. Coordinating with contractors and relevant parties on projects.");
  final TextEditingController experienceController2 = TextEditingController(text: "2017-2019 | Head Gardener\nHawknester House & Gardens, Hamptons, NY\nOverseeing a team of 4 gardeners and volunteers. Designing planting arrangements for the year. Maintaining the grounds and lawns. Planting flowers, shrubs, and trees. Managing the general upkeep of paths. Assessing soil condition.");
  final TextEditingController experienceController3 = TextEditingController(text: "2015-2017 | Gardener\nBloomsbury Botanic Gardens, Rochester, NY\nMaintaining the grounds and lawns. Planting flowers, shrubs, and trees. Managing the general upkeep of paths. Assessing soil condition. Building structures: decking area, new flower beds, bird habitats.");
  final TextEditingController educationController1 = TextEditingController(text: "2015 | Higher Diploma in Landscape Gardening\nBrimbury Community College, Rochester, NY");
  final TextEditingController educationController2 = TextEditingController(text: "2019 | B.A. in Landscape Architecture\nBrimbury Community College, New Haven, CT");
  final TextEditingController skillsController = TextEditingController(text: "Project Management\nCreative Mindset\nAttention to Detail\nTime Management\nProblem-Solving");
  final TextEditingController referencesController = TextEditingController(text: "Available upon request");
  final TextEditingController contactController = TextEditingController(text: "fredtru@email.site.com\nFredtrujillolandscapes.site.com\n311 555 0123\nHamptons, NY");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creative Professional'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCV,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadCVAsPDF,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage('https://i.imgur.com/8Q5QX6B.jpg '),
              
                
              ),
              TextField(
                controller: nameController,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              TextField(
                controller: titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "ABOUT ME",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              TextField(
                controller: aboutmeController,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

               Text(
                "CONTACT",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              TextField(
                controller: contactController,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),

              Text(
                "EDUCATION",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              TextField(
                controller: educationController1,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: educationController2,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

                Text(
                "EXPERIENCE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              TextField(
                controller: experienceController1,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.brown,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: experienceController2,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: experienceController3,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "SKILLS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              TextField(
                controller: skillsController,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),

             
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveCV() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/cv_data.txt');

    String cvData = '''
${nameController.text}
${titleController.text}

ABOUT ME
${aboutmeController.text}

EXPERIENCE
${experienceController1.text}
${experienceController2.text}
${experienceController3.text}

EDUCATION
${educationController1.text}
${educationController2.text}

SKILLS
${skillsController.text}

REFERENCES
${referencesController.text}

CONTACT
${contactController.text}
''';

    await file.writeAsString(cvData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CV Saved Successfully!')),
    );
  }

  void _downloadCVAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(nameController.text, style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(titleController.text, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("ABOUT ME", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(aboutmeController.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("EXPERIENCE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(experienceController1.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text(experienceController2.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text(experienceController3.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("EDUCATION", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(educationController1.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text(educationController2.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("SKILLS", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(skillsController.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("REFERENCES", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(referencesController.text, style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("CONTACT", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
              pw.Text(contactController.text, style: const pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/cv.pdf');
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: 'Here is my CV');
  }
}
