import 'dart:convert';
import 'package:corridle/const_file/const.dart';
import 'package:corridle/Store_Dashboard/shopdashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  PlatformFile? ownershipProofFile;

  @override
  void initState() {
    super.initState();
    phoneNumberController.text = widget.phone_number;
    emailController.text = widget.email;
  }

  Future<void> pickOwnershipProofFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        ownershipProofFile = result.files.first;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final storeId = "${widget.userUid.substring(0, 6)}_\${DateTime.now().millisecondsSinceEpoch}";
      final uri = Uri.parse(register_store);

      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'store_id': storeId,
        'user_uid': widget.userUid,
        'business_name': businessNameController.text.trim(),
        'phone_number': phoneNumberController.text.trim(),
        'email': emailController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'postal_code': postalCodeController.text.trim(),
      });

      if (ownershipProofFile != null && ownershipProofFile!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'ownership_proof',
          ownershipProofFile!.bytes!,
          filename: ownershipProofFile!.name,
        ));
      }

      try {
        final response = await request.send();
        final resultString = await response.stream.bytesToString();
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
            SnackBar(content: Text('❌ Server Error: ${result['message']}',)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Request failed: \$e')),
        );
      }
    }
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
                              _buildTextField("Business Category", categoryController),
                              _buildTextField("Business Description", descriptionController, maxLines: 3),
                              _buildTextField("Postal Code", postalCodeController),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: pickOwnershipProofFile,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text("Upload Proof of Ownership"),
                                  ),
                                  const SizedBox(width: 10),
                                  if (ownershipProofFile != null)
                                    Expanded(
                                      child: Text(ownershipProofFile!.name, overflow: TextOverflow.ellipsis),
                                    ),
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
}
