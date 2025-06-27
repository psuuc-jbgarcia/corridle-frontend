import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:corridle/const_file/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
Future<void> _sendResetRequest() async {
  final email = _emailController.text.trim();

  if (email.isEmpty) {
    _showDialog('Please enter your email address.');
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse(forgot_password),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    final result = json.decode(response.body);

    if (response.statusCode == 200 && result['success'] == true) {
      _showDialog('A password reset link has been sent to your email.');
    } else {
      _showDialog(result['message'] ?? 'Something went wrong.');
    }
  } catch (e) {
    print("ERROR: $e");
    _showDialog('Network error. Please try again later.');
  }

  setState(() => isLoading = false);
}


  void _showDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Forgot Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            )
          ],
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.75,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Reset Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendResetRequest,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Send Reset Link'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
