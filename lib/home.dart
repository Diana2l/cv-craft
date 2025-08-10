import 'package:cv_craft/screens/about.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cv_craft/screens/settings.dart';
import 'package:cv_craft/screens/report_screen.dart';
import 'package:cv_craft/screens/samples.dart';
import 'package:cv_craft/screens/cv_editor_screen.dart';
import 'package:cv_craft/auth/login.dart';
import 'package:cv_craft/screens/userpage.dart';
import 'package:cv_craft/models/cv_data.dart' as cv;
import 'package:cv_craft/auth/utility/globals.dart' as globals;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }

  Future<void> _loadSelectedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTemplate = prefs.getString('selected_template');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      bottomNavigationBar: _buildBottomNav(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'CV Craft',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: globals.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          if (_selectedTemplate != null)
            IconButton(
              icon: Icon(Icons.swap_horiz, color: Colors.blue),
              onPressed: () => Navigator.pushReplacementNamed(context, '/templates'),
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Settings(onThemeChanged: (bool _) {})),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 20),
            _buildProgressTracker(0.6), // Example: 60% CV completed
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildTemplatesCarousel(),
            const SizedBox(height: 24),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  // 🔹 Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text('Welcome!'),
          ),
          _drawerItem(Icons.home, 'Home', () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Userpage()),
          )),
          _drawerItem(Icons.settings, 'Settings', () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Settings(onThemeChanged: (bool _) {})),
          )),
          _drawerItem(Icons.report, 'Reports', () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportScreen(cvData: cv.CVData())),
          )),
          _drawerItem(Icons.type_specimen, 'CV + Cover Letter', () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CVEditorScreen(
                fontSize: 16,
                headerFontSize: 24,
                fontFamily: 'OpenSans',
                color: Colors.teal,
                objective: '',
                template: 'modern',
                templateImage: 'assets/images/Modern.png',
              ),
            ),
          )),
          _drawerItem(Icons.info, 'About Us', () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => About()),
          )),
          _drawerItem(Icons.logout, 'Log Out', () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Login()),
          )),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  // 🔹 Bottom Navigation
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Templates'),
        BottomNavigationBarItem(icon: Icon(Icons.create), label: 'Create'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacementNamed(context, '/templates');
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CVEditorScreen(
                fontSize: 16,
                headerFontSize: 24,
                fontFamily: 'OpenSans',
                color: Colors.teal,
                objective: '',
                template: 'modern',
                templateImage: 'assets/images/Modern.png',
              ),
            ),
          );
        }
      },
    );
  }

  // 🔹 Hero Section
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Back!', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Let’s create your perfect CV today!', style: GoogleFonts.poppins(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CVEditorScreen(
                    fontSize: 16,
                    headerFontSize: 24,
                    fontFamily: 'OpenSans',
                    color: Colors.teal,
                    objective: '',
                    template: 'modern',
                    templateImage: 'assets/images/Modern.png',
                  ),
                ),
              );
            },
            child: const Text('Get Started'),
          )
        ],
      ),
    );
  }

  // 🔹 Progress Tracker
  Widget _buildProgressTracker(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your CV Progress', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], color: Colors.blue),
        const SizedBox(height: 4),
        Text('${(progress * 100).toStringAsFixed(0)}% Complete', style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  // 🔹 Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(Icons.add_circle_outline, 'New CV', Colors.green, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CVEditorScreen(
                fontSize: 16,
                headerFontSize: 24,
                fontFamily: 'OpenSans',
                color: Colors.teal,
                objective: '',
                template: 'modern',
                templateImage: 'assets/images/Modern.png',
              ),
            ),
          );
        }),
        const SizedBox(width: 16),
        _quickAction(Icons.report, 'Reports', Colors.orange, () => Navigator.pushNamed(context, '/report_screen')),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Templates Carousel
  Widget _buildTemplatesCarousel() {
    final templates = [
      {'title': 'Classic', 'image': 'assets/images/classic.png'},
      {'title': 'Modern', 'image': 'assets/images/Modern.png'},
      {'title': 'Creative', 'image': 'assets/images/creative.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Templates', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/templates'), child: const Text('See All'))
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final template = templates[index];
              return GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/templates'),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: AssetImage(template['image']!), fit: BoxFit.cover),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(8),
                  child: Text(template['title']!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black45)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔹 Tips Section
  Widget _buildTipsSection() {
    final tips = [
      'Keep your CV concise and clear.',
      'Highlight achievements, not just duties.',
      'Use action verbs to describe experience.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CV Tips & Inspiration', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...tips.map((tip) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.lightbulb, color: Colors.amber),
                title: Text(tip, style: GoogleFonts.poppins()),
              ),
            )),
      ],
    );
  }
}
