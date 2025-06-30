// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Samples extends StatefulWidget {
  const Samples({super.key});

  @override
  _SamplesState createState() => _SamplesState();
}

class _SamplesState extends State<Samples> {
  String? _cvPath;
  final TextEditingController _coverLetterController = TextEditingController();

  
  

 
  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvPath = result.files.single.path;
      });
    }
  }

  Future<void> _generatePDF() async {
    if (_cvPath == null || _coverLetterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a cover letter and select a CV.')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final file = File(_cvPath!);

      if (!await file.exists()) {
        throw Exception('CV file does not exist');
      }

      final fileExtension = _cvPath!.split('.').last.toLowerCase();
      final fileBytes = await file.readAsBytes();

      if (fileExtension == 'png' || fileExtension == 'jpg' || fileExtension == 'jpeg') {
        final pdfImage = pw.MemoryImage(fileBytes);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              children: [
                pw.Text('Cover Letter', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(_coverLetterController.text),
                pw.SizedBox(height: 40),
                pw.Image(pdfImage),
              ],
            ),
          ),
        );
      } else {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              children: [
                pw.Text('Cover Letter', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(_coverLetterController.text),
                pw.SizedBox(height: 40),
                pw.Text('CV file is not an image and cannot be displayed.'),
              ],
            ),
          ),
        );
      }

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'application.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Generated and Shared Successfully!')),
      );
    } catch (e) {
      print("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compiler'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickCV,
              child: const Text('Select CV'),
            ),
            if (_cvPath != null) Text('Selected CV: $_cvPath'),
            const SizedBox(height: 20),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Cover Letter',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePDF,
              child: const Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
