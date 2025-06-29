import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:corridle/Authentication/sign_up.dart';
import 'package:corridle/Store_Dashboard/businessdashboard.dart';
import 'package:corridle/User_Dashboard/user_dasboard.dart';
import 'package:corridle/authentication/information.dart';
import 'package:corridle/const_file/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      showError('Please enter both email and password.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(login_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final userId = data['userId'];
          final userType = data['userType'];
          final hasStoreInfo = int.tryParse(data['has_store_info'].toString()) ?? 0;
          final storeId = data['storeId']?.toString() ?? '';
          final email = data['email'];

            // ✅ Save session
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userId);
  await prefs.setString('email', email);
  await prefs.setString('user_type', userType);
  if (userType == 'Shop Owner') {
    await prefs.setString('store_id', storeId);
  }
          AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.scale,
            title: 'Login Successful!',
            desc: 'Welcome back! Redirecting to your dashboard...',
            btnOkText: 'Continue',
            btnOkOnPress: () {
             if (hasStoreInfo == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InformationScreen(userUid: userId, email: email),
      ),
    );
  } else if (userType == 'Shop Owner') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ShopownerDashboard(
          userUid: userId,
          storeid: storeId, // ✅ pass storeId here
        ),
      ),
    );
  }
 else if (userType == 'Customer') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => UserDashboardScreen(userUid: userId)),
                );
              } else if (userType == 'ADMIN') {
                showError('Admin dashboard is under development.');
              } else {
                showError('Unknown user type.');
              }
            },
            width: MediaQuery.of(context).size.width * 0.75,
          ).show();
        } else {
          showError(data['message'] ?? 'Login failed');
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error: $e or The database is offline.');
    }
  }

  void showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Oops!',
      desc: message,
      btnOkOnPress: () {},
      width: MediaQuery.of(context).size.width * 0.75,
    ).show();
  }

  void showResetDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Forgot Password',
      desc: message,
      btnOkOnPress: () {},
      width: MediaQuery.of(context).size.width * 0.75,
    ).show();
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
              const Text('Welcome back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() => _passwordVisible = !_passwordVisible);
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final TextEditingController _resetEmailController =
                              TextEditingController();
                          bool isSubmitting = false;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  Future<void> sendResetRequest() async {
                                    final email = _resetEmailController.text.trim();

                                    if (email.isEmpty) {
                                      showResetDialog('Please enter your email address.');
                                      return;
                                    }

                                    setState(() => isSubmitting = true);

                                    try {
                                      final response = await http.post(
                                        Uri.parse(forgot_password),
                                        headers: {'Content-Type': 'application/json'},
                                        body: jsonEncode({'email': email}),
                                      );

                                      final result = jsonDecode(response.body);
                                      Navigator.of(context).pop();

                                      if (response.statusCode == 200 &&
                                          result['success'] == true) {
                                        showResetDialog(
                                            'A password reset link has been sent to your email.');
                                      } else {
                                        showResetDialog(
                                            result['message'] ?? 'Something went wrong.');
                                      }
                                    } catch (e) {
                                      Navigator.of(context).pop();
                                      showResetDialog('Network error. Please try again later.');
                                    }

                                    setState(() => isSubmitting = false);
                                  }

                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    backgroundColor: Colors.white,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 300),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Reset Password',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: _resetEmailController,
                                              decoration: const InputDecoration(
                                                labelText: 'Enter your email',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.emailAddress,
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(),
                                                ),
                                                ElevatedButton(
                                                  onPressed: isSubmitting
                                                      ? null
                                                      : sendResetRequest,
                                                  child: isSubmitting
                                                      ? const SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : const Text('Send'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
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
                      child: const Text('Create account',
                          style: TextStyle(color: Colors.black)),
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
                Text('Terms of Use  Privacy Policy  Support',
                    style: TextStyle(fontSize: 14)),
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
