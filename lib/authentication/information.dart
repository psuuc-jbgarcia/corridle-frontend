import 'dart:convert';
import 'package:corridle/User_Dashboard/user_dasboard.dart';
import 'package:corridle/const_file/const.dart';
import 'package:corridle/screens/shopdashboard.dart';
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
    final userUid = widget.userUid ?? '000000';
    final url = Uri.parse(save_info);

    if (_dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid Date of Birth')),
      );
      return;
    }

    Map<String, dynamic> userData = {
      'user_uid': userUid,
      'firstName': _firstNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'dateOfBirth': _dobController.text.trim(), // Format: YYYY-MM-DD
      'email': _emailController.text.trim(),
      'userType': _userType, // For user table update
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      final data = jsonDecode(response.body);
      print('RESPONSE: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Information saved.')),
        );

        if (_userType == 'Customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ShopScreen(userUid: userUid)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save information: $e')),
      );
    }
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
                        Expanded(child: _buildTextField('M.I. (Optional)', _middleNameController)),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
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
