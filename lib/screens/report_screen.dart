import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cv_craft/models/cv_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class ReportScreen extends StatefulWidget {
  final CVData cvData;
  final Function()? onUpdate;

  const ReportScreen({
    super.key,
    required this.cvData,
    this.onUpdate,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
  }

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Returns a map of CV fields and their completion status
  Map<String, bool> _getCompletionStatus() {
    final cv = widget.cvData;
    return {
      'Name': cv.name.trim().isNotEmpty,
      'Title': cv.title.trim().isNotEmpty,
      'Summary': cv.summary.trim().isNotEmpty,
      'Email': cv.email.trim().isNotEmpty,
      'Phone': cv.phone.trim().isNotEmpty,
      'LinkedIn': cv.linkedin.trim().isNotEmpty,
      'Address': cv.address.trim().isNotEmpty,
      'Experience': cv.experience.isNotEmpty,
      'Education': cv.education.isNotEmpty,
      'Skills': cv.skills.isNotEmpty,
      'Projects': cv.projects.isNotEmpty,
      'Languages': cv.languages.isNotEmpty,
      'Certifications': cv.certifications.isNotEmpty,
    };
  }
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Build a status chip for each CV section
  Widget _buildStatusChip(BuildContext context, {required String label, required bool isComplete}) {
    return Container(
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            color: isComplete ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isComplete ? Colors.green.shade800 : Colors.grey.shade800,
                fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Generate improvement tips based on missing sections
  List<Widget> _getImprovementTips(Map<String, bool> fields) {
    final tips = <Widget>[];
    
    if (!fields['Name']!) {
      tips.add(_buildTipItem('Add your full name to make your CV more personal'));
    }
    if (!fields['Title']!) {
      tips.add(_buildTipItem('Include a professional title that highlights your expertise'));
    }
    if (!fields['Summary']!) {
      tips.add(_buildTipItem('Write a compelling summary that showcases your key achievements'));
    }
    if (!fields['Email']! || !fields['Phone']!) {
      tips.add(_buildTipItem('Make sure to add your contact information'));
    }
    if (!fields['Experience']!) {
      tips.add(_buildTipItem('Add your work experience with key responsibilities and achievements'));
    }
    if (!fields['Education']!) {
      tips.add(_buildTipItem('Include your educational background and any relevant certifications'));
    }
    if (!fields['Skills']!) {
      tips.add(_buildTipItem('List your key skills that are relevant to the job you\'re applying for'));
    }
    if (!fields['Projects']!) {
      tips.add(_buildTipItem('Highlight any significant projects you\'ve worked on'));
    }
    if (!fields['Languages']!) {
      tips.add(_buildTipItem('Mention any additional languages you speak'));
    }
    
    return tips;
  }
  
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildReportContent(context),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Get current completion status
    final fields = _getCompletionStatus();
    final filled = fields.values.where((v) => v).length;
    final total = fields.length;
    final percentage = filled / total;
    final percentageText = '${(percentage * 100).toStringAsFixed(1)}%';
    
    // Calculate completion percentage with color
    final Color progressColor = percentage < 0.5
        ? Colors.red
        : percentage < 0.8
            ? Colors.orange
            : Colors.green;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  Colors.teal.shade900.withOpacity(0.9),
                  Colors.teal.shade800.withOpacity(0.7),
                  Colors.grey.shade900,
                ]
              : [
                  Colors.teal.shade50,
                  Colors.teal.shade100,
                  Colors.grey.shade100,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('CV Progress Report'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CV Completion',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            percentageText,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearPercentIndicator(
                        lineHeight: 20.0,
                        percent: percentage,
                        backgroundColor: Colors.grey[300],
                        progressColor: progressColor,
                        barRadius: const Radius.circular(10),
                        animation: true,
                        animationDuration: 1000,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$filled out of $total sections completed',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sections Status
              Text(
                'Sections Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
                children: fields.entries.map((entry) {
                  return _buildStatusChip(
                    context,
                    label: entry.key,
                    isComplete: entry.value,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Tips for improvement
              if (percentage < 1.0) ...[
                Text(
                  'Tips to improve your CV:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._getImprovementTips(fields),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
          