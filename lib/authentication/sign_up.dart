import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:corridle/authentication/information.dart';
import 'package:corridle/const_file/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:corridle/Authentication/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool isTermsAccepted = false;
  bool _showPasswordHint = false;

  late AnimationController _controller;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = ColorTween(
      begin: const Color.fromARGB(255, 73, 166, 254),
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    if (!isTermsAccepted) {
      _showError('You must accept the terms and privacy policy.');
      return;
    }

    final url = Uri.parse(register_url);

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          final String userId = data['user_id'].toString();
          final String userEmail = data['email'];

          await AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            width: MediaQuery.of(context).size.width * 0.75,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Registration Successful!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome to Corridle! Proceeding to setup your information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => InformationScreen(userUid: userId, email: userEmail)),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ).show();
        } else {
          _showError(data['message'] ?? 'Registration failed.');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error: $e or The database server is offline');
    }
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      width: MediaQuery.of(context).size.width * 0.75,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Oops!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ).show();
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.cancel, color: isMet ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: isMet ? Colors.green : Colors.red)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo.jpg', height: 120),
              const SizedBox(height: 20),
              const Text('Register', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _glowAnimation.value ?? Colors.blue,
                          blurRadius: 15,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    width: 350,
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Enter Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                          onTap: () => setState(() => _showPasswordHint = true),
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: () => setState(() => _showPasswordHint = false),
                        ),
                        if (_showPasswordHint)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequirement("One uppercase letter", RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                                _buildRequirement("One lowercase letter", RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                                _buildRequirement("One number", RegExp(r'\d').hasMatch(_passwordController.text)),
                                _buildRequirement("One special character", RegExp(r'[!@#\$%^&*]').hasMatch(_passwordController.text)),
                                _buildRequirement("At least 8 characters", _passwordController.text.length >= 8),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Re-enter Password',
                            border: const OutlineInputBorder(),
                            errorText: _passwordController.text == _confirmPasswordController.text || _confirmPasswordController.text.isEmpty
                                ? null
                                : "Passwords do not match",
                            suffixIcon: IconButton(
                              icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: isTermsAccepted,
                              onChanged: (value) => setState(() => isTermsAccepted = value ?? false),
                            ),
                            const Flexible(
                              child: Text("I accept the Terms & Privacy Policy", style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
