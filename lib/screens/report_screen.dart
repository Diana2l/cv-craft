import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cv_craft/models/cv_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      'name': cv.name != null && cv.name!.isNotEmpty,
      'email': cv.email != null && cv.email!.isNotEmpty,
      'phone': cv.phone != null && cv.phone!.isNotEmpty,
      'education': cv.education != null && cv.education!.isNotEmpty,
      'experience': cv.experience != null && cv.experience!.isNotEmpty,
      'skills': cv.skills != null && cv.skills!.isNotEmpty,
      // Add more fields as needed
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

  @override
  Widget build(BuildContext context) {
    return _buildReportContent(context);
  }

  Widget _buildReportContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Get current completion status
    final fields = _getCompletionStatus();
    final filled = fields.values.where((v) => v).length;
    final total = fields.length;
    final percentage = filled / total;
    
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your CV Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.teal.shade900,
                          ),
                        ),
                        // You can add more widgets here if needed
                      ],
                    ),
                  ),
                ),
                // You can add more widgets here if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
          