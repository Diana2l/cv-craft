// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_craft/auth/register.dart';
import 'package:cv_craft/auth/forgot_password.dart';
import 'package:cv_craft/screens/userpage.dart';
import 'package:cv_craft/screens/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _roleFocus = FocusNode();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // State variables
  bool _obscureText = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _selectedRole;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Constants
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  final List<String> _roles = ['User', 'Admin'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _roleFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        emailController.text = prefs.getString('savedEmail') ?? '';
        passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('savedEmail', emailController.text.trim());
      await prefs.setString('savedPassword', passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  // Input validators
  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? roleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a role';
    }
    return null;
  }

  Future<void> login() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      _showMessage('Please select a role', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if account is locked
      if (_failedAttempts >= _maxFailedAttempts) {
        final timeSinceLastAttempt = DateTime.now().difference(_lastFailedAttempt!);
        if (timeSinceLastAttempt < _lockoutDuration) {
          final remainingTime = _lockoutDuration - timeSinceLastAttempt;
          _showMessage(
            'Too many failed attempts. Please try again in ${remainingTime.inMinutes} minutes ${remainingTime.inSeconds % 60} seconds.',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        } else {
          // Reset failed attempts if lockout period has passed
          _failedAttempts = 0;
        }
      }

      // Sign in with email and password
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      ).catchError((error) {
        // Handle specific auth errors
        if (error is FirebaseAuthException) {
          throw error;
        }
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'An unknown error occurred. Please try again.',
        );
      }, test: (e) => e is FirebaseAuthException);

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        await _sendEmailVerification(userCredential.user!);
        _showEmailVerificationDialog();
        setState(() => _isLoading = false);
        return;
      }

      // Get user document from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user record found. Please register first.',
        );
      }

      // Get user data
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = (userData['role'] as String?)?.toLowerCase() ?? 'user';
      final selectedRole = _selectedRole?.toLowerCase() ?? '';

      // Check if user is active
      if (userData['status'] == 'suspended') {
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'This account has been suspended. Please contact support.',
        );
      }

      // Validate role
      if (selectedRole != userRole) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'You are not authorized to access the ${_selectedRole} role.',
        );
      }

      // Update last login timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Save credentials if remember me is checked
      await _saveCredentials();

      // Reset failed attempts on successful login
      _failedAttempts = 0;

      // Show success message
      if (mounted) {
        _showMessage('Login successful!', isError: false);
      }

      // Navigate based on role
      _navigateBasedOnRole(userRole);
      
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      setState(() => _isLoading = false);
    } catch (e) {
      _showMessage('An unexpected error occurred. Please try again later.',
          isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      debugPrint('Error sending verification email: $e');
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'A verification email has been sent to your email address. Please verify your email to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () => _auth.currentUser?.reload().then((_) {
                    if (_auth.currentUser?.emailVerified ?? false) {
                      Navigator.pop(context);
                      login();
                    } else {
                      _showMessage('Email not verified yet.', isError: true);
                    }
                  }),
                  child: const Text('I\'ve verified'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBasedOnRole(String role) {
    final route = role == 'admin' 
        ? MaterialPageRoute(builder: (context) => const AdminDashboard())
        : MaterialPageRoute(builder: (context) => Userpage());
        
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    bool isCritical = false;
    bool showLockoutWarning = false;

    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email. Please register first.';
        _failedAttempts++;
        _lastFailedAttempt = DateTime.now();
        break;
      case 'wrong-password':
        _failedAttempts++;
        _lastFailedAttempt = DateTime.now();
        final remainingAttempts = _maxFailedAttempts - _failedAttempts;
        
        if (remainingAttempts > 0) {
          message = 'Incorrect password. $remainingAttempts ${remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining.';
        } else {
          message = 'Account locked. Please try again in ${_lockoutDuration.inMinutes} minutes.';
          showLockoutWarning = true;
        }
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support.';
        isCritical = true;
        break;
      case 'too-many-requests':
        message = 'Too many login attempts. Please try again later.';
        isCritical = true;
        showLockoutWarning = true;
        break;
      case 'permission-denied':
        message = e.message ?? 'You do not have permission to access this resource.';
        isCritical = true;
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        _emailFocus.requestFocus();
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        isCritical = true;
        break;
      case 'requires-recent-login':
        message = 'Session expired. Please sign in again.';
        isCritical = true;
        _auth.signOut();
        break;
      default:
        message = e.message ?? 'An unexpected error occurred. Please try again.';
    }

    // Show error message
    _showMessage(message, isError: true);
    
    // Handle critical errors
    if (isCritical) {
      _formKey.currentState?.reset();
      passwordController.clear();
    }
    
    // Show lockout warning if needed
    if (showLockoutWarning) {
      _showLockoutWarning();
    }
  }
  
  void _showLockoutWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Account Locked'),
        content: Text(
          'For security reasons, your account has been temporarily locked. ' 
          'Please try again in ${_lockoutDuration.inMinutes} minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Sign out first to force account selection
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-signin-cancelled',
          message: 'Google sign in was cancelled',
        );
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Verify the ID token with Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw FirebaseAuthException(
          code: 'google-signin-failed',
          message: 'Failed to sign in with Google',
        );
      }
      
      // Check if it's a new user
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'role': 'user', // Default role for Google sign-in
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'status': 'active',
          'provider': 'google.com',
          'emailVerified': user.emailVerified,
        });
      } else {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'emailVerified': user.emailVerified,
          if (user.photoURL != null) 'photoURL': user.photoURL,
        });
      }
      
      // Navigate to user page (Google sign-in defaults to regular user)
      _navigateBasedOnRole(userDoc.data()?['role']?.toString().toLowerCase() ?? 'user');
      
    } on FirebaseAuthException catch (e) {
      if (e.code != 'google-signin-cancelled') {
        _showMessage('Google sign in failed: ${e.message}', isError: true);
      }
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed') {
        _showMessage('Google sign in failed. Please try again.', isError: true);
      } else {
        _showMessage('An error occurred during Google sign in', isError: true);
      }
      debugPrint('Google sign in error: $e');
    } catch (e) {
      _showMessage('An unexpected error occurred', isError: true);
      debugPrint('Unexpected error during Google sign in: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.teal.shade900,
                    Colors.teal.shade800,
                    Colors.teal.shade700,
                  ]
                : [
                    Colors.teal.shade50,
                    Colors.teal.shade100,
                    Colors.teal.shade200,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Welcome Text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_person,
                              size: 60,
                              color: isDarkMode ? Colors.white : Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.teal.shade900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue to CV Craft',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Form Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            TextFormField(
                              controller: emailController,
                              focusNode: _emailFocus,
                              validator: emailValidator,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).requestFocus(_passwordFocus),
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: passwordController,
                              focusNode: _passwordFocus,
                              validator: passwordValidator,
                              obscureText: _obscureText,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).requestFocus(_roleFocus),
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remember Me Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.teal,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),

                                // Forgot Password
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPassword(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.teal.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Role Selection
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              focusNode: _roleFocus,
                              validator: roleValidator,
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.5)
                                    : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Divider with "or" text
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: isDarkMode
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: isDarkMode
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google Sign In Button
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDarkMode
                                    ? Colors.white
                                    : Colors.grey.shade800,
                                backgroundColor: isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.3)
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/logos/google.png',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.g_mobiledata, size: 28),
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.teal.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
