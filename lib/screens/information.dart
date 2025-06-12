import 'dart:convert';
import 'package:corridle/User_Dashboard/user_dasboard.dart';
import 'package:corridle/screens/shopdashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:corridle/screens/customer.dart';

class InformationScreen extends StatefulWidget {
  final String userUid;
  final String? googleDisplayName;

  const InformationScreen({
    super.key,
    required this.userUid,
    this.googleDisplayName,
    required Future<Null> Function(dynamic userType) onInfoSubmitted,
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

  Future<void> _submitInformation() async {
    final url = Uri.parse('https://yourdomain.com/api/save_user_info.php'); // <-- replace with your real PHP API URL

    Map<String, dynamic> userData = {
      'user_uid': widget.userUid,
      'firstName': _firstNameController.text.trim(),
      'middleName': _middleNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'email': _emailController.text.trim(),
      'userType': _userType,
      'informationCompleted': true,
    };

    if (_userType == 'Shop Owner') {
      userData['storeId'] = 'store_${widget.userUid.substring(0, 6)}';
    } else if (_userType == 'Customer') {
      userData['customerId'] = 'customer_${widget.userUid.substring(0, 6)}';
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final respData = jsonDecode(response.body);
        if (respData['success'] == true) {
          if (_userType == 'Customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ShopScreen(userUid: widget.userUid)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${respData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save information: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.googleDisplayName != null) {
      List<String> nameParts = widget.googleDisplayName!.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts[0];
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.last;
        }
      }
    }
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
              Image.asset('assets/images/Logo.jpg', height: 100),
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
                        Expanded(child: _buildTextField('Date of Birth', _dobController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField('Email', _emailController),
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
              const Text(
                "Terms of Use     Privacy Policy     Support",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              const Text("© Corridle 2025", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
