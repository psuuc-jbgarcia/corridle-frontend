import 'dart:convert';
import 'dart:io';
import 'package:corridle/const_file/const.dart';
import 'package:corridle/Store_Dashboard/shopdashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StoreRegistrationScreen extends StatefulWidget {
  final String userUid;
  final String phone_number;
  final String email;

  const StoreRegistrationScreen({
    Key? key,
    required this.userUid,
    required this.phone_number,
    required this.email,
  }) : super(key: key);

  @override
  _StoreRegistrationScreenState createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedPartnership;
  String? ownershipStatus;
  File? ownershipProofImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phone_number;
    emailController.text = widget.email;
  }

  Future<void> pickOwnershipProofImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        ownershipProofImage = File(pickedFile.path);
      });
    }
  }
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final storeId = "store_${widget.userUid.substring(0, 6)}_${DateTime.now().millisecondsSinceEpoch}";
    final uri = Uri.parse(register_store); // e.g. http://yourdomain.com/api/register_store.php

    final request = http.MultipartRequest('POST', uri);
    request.fields.addAll({
      'store_id': storeId,
      'user_uid': widget.userUid,
      'business_name': businessNameController.text.trim(),
      'phone_number': phoneNumberController.text.trim(),
      'email': emailController.text.trim(),
      'category': selectedCategory!,
      'partnership_type': selectedPartnership!,
      'description': descriptionController.text.trim(),
      'is_owner': ownershipStatus!,
    });

    if (ownershipProofImage != null) {
      final filePath = ownershipProofImage!.path;
      print("📷 Selected image: $filePath");
      request.files.add(await http.MultipartFile.fromPath(
        'ownership_proof',
        filePath,
        filename: path.basename(filePath),
      ));
    }

    try {
      print("📤 Sending registration request...");
      print("➡️ Fields: ${request.fields}");

      final response = await request.send();
      final resultString = await response.stream.bytesToString();

      print("📥 Raw response: $resultString");

      final result = json.decode(resultString);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store Registered Successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ShopScreen(userUid: widget.userUid)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Server Error: ${result['message']}')),
        );
      }
    } catch (e) {
      print("❌ Error sending request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(child: Image.asset('assets/images/Logo.jpg', height: 100)),
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 800,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField("Business Name", businessNameController),
                              _buildTextField("Phone Number", phoneNumberController, inputType: TextInputType.phone),
                              _buildTextField("Email", emailController, inputType: TextInputType.emailAddress),
                              DropdownButtonFormField(
                                decoration: const InputDecoration(labelText: "Business Category"),
                                value: selectedCategory,
                                items: ['Electrician', 'Plumbing', 'Yard Work', 'Snow Removal', 'Mechanic', 'Etc.']
                                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                    .toList(),
                                onChanged: (val) => setState(() => selectedCategory = val as String),
                                validator: (val) => val == null ? "Select a category" : null,
                              ),
                              DropdownButtonFormField(
                                decoration: const InputDecoration(labelText: "Business Partnership"),
                                value: selectedPartnership,
                                items: [
                                  'Sole proprietorship',
                                  'LLC',
                                  'C Corporation',
                                  'S Corporation',
                                  'Nonprofit corporation',
                                  'Limited Partnership',
                                  'Cooperative (LP)'
                                ]
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                    .toList(),
                                onChanged: (val) => setState(() => selectedPartnership = val as String),
                                validator: (val) => val == null ? "Select a partnership" : null,
                              ),
                              _buildTextField("Business Description", descriptionController, maxLines: 3),
                              DropdownButtonFormField(
                                decoration: const InputDecoration(labelText: "Are you the Business Owner?"),
                                value: ownershipStatus,
                                items: ['Yes', 'No', 'An employee']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (val) => setState(() => ownershipStatus = val as String),
                                validator: (val) => val == null ? "Select ownership status" : null,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: pickOwnershipProofImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text("Upload Proof of Ownership"),
                                  ),
                                  const SizedBox(width: 10),
                                  if (ownershipProofImage != null)
                                    Text(path.basename(ownershipProofImage!.path), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                                ),
                                child: const Text("Register Store"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            width: double.infinity,
            color: Colors.grey.shade300,
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

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        validator: (value) => value == null || value.isEmpty ? "This field cannot be empty" : null,
      ),
    );
  }
}
