import 'dart:convert';
import 'package:corridle/Authentication/sign_up.dart';
import 'package:corridle/Store_Dashboard/businessdashboard.dart';
import 'package:corridle/User_Dashboard/user_dasboard.dart';
import 'package:corridle/authentication/information.dart';
import 'package:corridle/const_file/const.dart';
import 'package:corridle/Store_Dashboard/shopdashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

 Future<void> signInWithEmail(BuildContext context) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    showError(context, 'Please enter both email and password.');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(login_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final userId = data['userId'];
        final userType = data['userType'];
        final hasStoreInfo = int.tryParse(data['has_store_info'].toString()) ?? 0;

        if (hasStoreInfo == 0) {
          // Navigate to InformationScreen to complete profile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => InformationScreen(
                userUid: userId,
                email: email,
              ),
            ),
          );
        } else {
          // Role-based navigation
          if (userType == 'Shop Owner') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ShopownerDashboard(userUid: userId,),
              ),
            );
          } else if (userType == 'Customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>  UserDashboardScreen(userUid: userId,),
              ),
            );
          } else if (userType == 'ADMIN') {
            showError(context, 'Admin dashboard is under development.');
          } else {
            showError(context, 'Unknown user type.');
          }
        }
      } else {
        showError(context, data['message'] ?? 'Login failed');
      }
    } else {
      showError(context, 'Server error: ${response.statusCode}');
    }
  } catch (e) {
    showError(context, 'Error: $e');
  }
}


  void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Column(
            children: [
              Image.asset('assets/images/Logo.jpg', height: 120),
              const SizedBox(height: 20),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => signInWithEmail(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text('Create account', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.grey.shade300,
            width: double.infinity,
            child: const Column(
              children: [
                Text('Terms of Use  Privacy Policy  Support', style: TextStyle(fontSize: 14)),
                SizedBox(height: 5),
                Text('© Corridle 2025', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
