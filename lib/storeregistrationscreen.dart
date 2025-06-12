import 'package:corridle/screens/shopdashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StoreRegistrationScreen extends StatefulWidget {
  final String userUid;

  const StoreRegistrationScreen({Key? key, required this.userUid}) : super(key: key);

  @override
  _StoreRegistrationScreenState createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ownershipProofController = TextEditingController();

  String? selectedCategory;
  String? selectedPartnership;
  String? ownershipStatus;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final storeId = "store_${widget.userUid.substring(0, 6)}_${DateTime.now().millisecondsSinceEpoch}";

      final uri = Uri.parse("http://yourserver.com/api/register_store.php");
      try {
        final response = await http.post(uri, body: {
          'store_id': storeId,
          'user_uid': widget.userUid,
          'business_name': businessNameController.text.trim(),
          'phone_number': phoneNumberController.text.trim(),
          'email': emailController.text.trim(),
          'category': selectedCategory!,
          'partnership_type': selectedPartnership!,
          'description': descriptionController.text.trim(),
          'ownership_proof': ownershipProofController.text.trim(),
          'is_owner': ownershipStatus!,
        });

        final result = json.decode(response.body);
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
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                                    .toList(),
                                onChanged: (val) => setState(() => selectedCategory = val as String),
                                validator: (value) => value == null ? "Please select a category" : null,
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
                                validator: (value) => value == null ? "Please select a partnership type" : null,
                              ),
                              _buildTextField("Business Description", descriptionController, maxLines: 3),
                              DropdownButtonFormField(
                                decoration: const InputDecoration(labelText: "Are you the Business Owner?"),
                                value: ownershipStatus,
                                items: ['Yes', 'No', 'An employee']
                                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                    .toList(),
                                onChanged: (val) => setState(() => ownershipStatus = val as String),
                                validator: (value) => value == null ? "Please select ownership status" : null,
                              ),
                              _buildTextField("Proof of Ownership (Optional)", ownershipProofController, maxLines: 3),
                              const SizedBox(height: 15),
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

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
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
