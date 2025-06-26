import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:corridle/Authentication/login.dart';
import 'package:corridle/Store_Dashboard/storeregistrationscreen.dart';
import 'package:corridle/User_Dashboard/user_dasboard.dart';
import 'package:corridle/const_file/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InformationScreen extends StatefulWidget {
  final String? userUid;
  final String? email;

  const InformationScreen({
    super.key,
    required this.userUid,
    required this.email,
  });

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _userType = 'Customer';

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
  }

  Future<void> _submitInformation() async {
    if (!_formKey.currentState!.validate()) return;

    final userUid = widget.userUid ?? '000000';
    final url = Uri.parse(save_info);

    Map<String, dynamic> userData = {
      'user_uid': userUid,
      'firstName': _firstNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'email': _emailController.text.trim(),
      'userType': _userType,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('RAW RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DECODED JSON: $data');

        if (data['success'] == true) {
          _showSuccessDialog("Information saved.", onClose: () {
            if (_userType == 'Customer') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreRegistrationScreen(
                    userUid: userUid,
                    email: _emailController.text.trim(),
                    phone_number: _phoneNumberController.text.trim(),
                  ),
                ),
              );
            }
          });
        } else {
          _showErrorDialog('Server Error: ${data['message']}');
        }
      } else {
        _showErrorDialog('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to send request: $e');
    }
  }

  void _showErrorDialog(String message) {
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
              'Error',
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

  void _showSuccessDialog(String message, {required VoidCallback onClose}) {
    AwesomeDialog(
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
              'Success',
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
                onPressed: onClose,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final safeUserId = widget.userUid ?? 'null (not provided)';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'User ID: $safeUserId',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('First Name', _firstNameController)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('M.I. (Optional)', _middleNameController, required: false)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Last Name', _lastNameController),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Phone Number', _phoneNumberController)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDatePickerField('Date of Birth', _dobController)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField('Email', _emailController, readOnly: true),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _userType,
                        items: const [
                          DropdownMenuItem(value: 'Customer', child: Text('Customer')),
                          DropdownMenuItem(value: 'Shop Owner', child: Text('Shop Owner')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _userType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitInformation,
                        child: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Terms of Use     Privacy Policy     Support",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              const Text("© Corridle 2025", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toIso8601String().split('T')[0];
        }
      },
    );
  }
}
