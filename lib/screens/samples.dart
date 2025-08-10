// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, avoid_print

import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import 'package:printing/printing.dart';
import 'package:cv_craft/screens/cv_editor_screen.dart';

class Samples extends StatefulWidget {
  const Samples({super.key});

  @override
  _SamplesState createState() => _SamplesState();
}

class _SamplesState extends State<Samples> {
  Uint8List? _cvBytes;
  String? _cvFileName;
  String? _cvText;
  final TextEditingController _coverLetterController = TextEditingController();
  bool _loading = false;

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Important to get bytes directly
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final text = await compute(_extractTextFromPdf, bytes); // run in background

        setState(() {
          _cvBytes = bytes;
          _cvFileName = result.files.single.name;
          _cvText = text;
        });

        print('File selected: $_cvFileName');
      } else {
        print('No file selected or file bytes null.');
      }
    } catch (e) {
      print('File pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  // Now a top-level static function for background processing
  static String _extractTextFromPdf(Uint8List pdfBytes) {
    final document = sfpdf.PdfDocument(inputBytes: pdfBytes);
    final buffer = StringBuffer();
    final extractor = sfpdf.PdfTextExtractor(document);

    for (int i = 0; i < document.pages.count; i++) {
      final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
      buffer.writeln(pageText);
    }

    document.dispose();
    return buffer.toString();
  }

  Future<void> _callAIToGenerateCoverLetter() async {
    if (_cvBytes == null || _cvText == null || _cvText!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid CV PDF.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('http://127.0.0.1:3000/generate-cover-letter');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cv_text': _cvText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _coverLetterController.text = data['cover_letter'] ?? 'No cover letter generated.';
      } else {
        throw Exception('API Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _generatePDF() async {
    if (_cvBytes == null || _coverLetterController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provide a cover letter and select a CV.')),
      );
      return;
    }

    try {
      final document = sfpdf.PdfDocument();

      
      final coverPage = document.pages.add();
      final font = sfpdf.PdfStandardFont(sfpdf.PdfFontFamily.helvetica, 12);
      final boldFont = sfpdf.PdfStandardFont(
        sfpdf.PdfFontFamily.helvetica,
        18,
        style: sfpdf.PdfFontStyle.bold,
      );
      coverPage.graphics.drawString(
        'Cover Letter',
        boldFont,
        bounds: const Rect.fromLTWH(0, 0, 500, 40),
      );
      coverPage.graphics.drawString(
        _coverLetterController.text,
        font,
        bounds: const Rect.fromLTWH(0, 50, 500, 800),
      );

      final cvDoc = sfpdf.PdfDocument(inputBytes: _cvBytes);
      for (int i = 0; i < cvDoc.pages.count; i++) {
        final page = cvDoc.pages[i];
        final newPage = document.pages.add();
        newPage.graphics.drawPdfTemplate(page.createTemplate(), const Offset(0, 0));
      }
      cvDoc.dispose();

      final finalPdf = Uint8List.fromList(await document.save());
      document.dispose();

      await Printing.sharePdf(bytes: finalPdf, filename: 'application_combined.pdf');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Generated and Shared!')),
      );
    } catch (e) {
      print('PDF Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV + Cover Letter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_document),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CVEditorScreen(
                    fontSize: 16,
                    headerFontSize: 24,
                    fontFamily: 'OpenSans',
                    color: Colors.teal,
                    objective: _cvText ?? '',
                    template: 'modern',
                    templateImage: 'assets/images/Modern.png',
                  ),
                ),
              );
            },
            tooltip: 'Edit in CV Editor',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickCV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select CV'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                Text('Selected: ${_cvFileName ?? "None"}', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                
                ElevatedButton.icon(
                  onPressed: _callAIToGenerateCoverLetter,
                  icon: const Icon(Icons.smart_toy),
                  label: const Text('Generate Cover Letter (AI)'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _coverLetterController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Cover Letter',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'AI Assistant is generating your cover letter...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
