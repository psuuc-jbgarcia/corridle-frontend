import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({Key? key}) : super(key: key);

  @override
  _StoreProfileScreenState createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController partnershipController = TextEditingController();

  List<String> featuredPhotos = [];
  String? storeId;
  String? businessLogoUrl;
  bool isLoading = true;
  bool isUploadingLogo = false;
  bool isOwner = true; // assume owner after login
  String userUid = "your_user_uid"; // Replace with your login UID
  String baseUrl = "http://yourserver.com/api"; // <-- Change this

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_store.php'),
      body: {'user_uid': userUid},
    );

    final result = json.decode(response.body);
    if (result['success']) {
      final data = result['store'];
      setState(() {
        storeId = data['id'].toString();
        businessNameController.text = data['business_name'] ?? '';
        categoryController.text = data['category'] ?? '';
        descriptionController.text = data['description'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone_number'] ?? '';
        partnershipController.text = data['partnership_type'] ?? '';
        businessLogoUrl = data['businessLogo'];
        featuredPhotos = List<String>.from(data['featuredPhotos'] ?? []);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      _showSnackBar(result['message']);
    }
  }

  Future<void> _updateStore() async {
    if (storeId == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/update_store.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'store_id': int.parse(storeId!),
        'business_name': businessNameController.text,
        'category': categoryController.text,
        'description': descriptionController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
        'partnership_type': partnershipController.text,
      }),
    );

    final result = json.decode(response.body);
    if (result['success']) {
      _showSnackBar("Store information updated.");
    } else {
      _showSnackBar(result['message']);
    }
  }

  Future<void> _uploadLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || storeId == null) return;

    setState(() => isUploadingLogo = true);

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_logo.php'))
      ..fields['store_id'] = storeId!
      ..files.add(await http.MultipartFile.fromPath('logo', image.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final result = json.decode(respStr);

    if (result['success']) {
      setState(() {
        businessLogoUrl = result['url'];
        isUploadingLogo = false;
      });
      _showSnackBar("Logo uploaded.");
    } else {
      setState(() => isUploadingLogo = false);
      _showSnackBar(result['message']);
    }
  }

  Future<void> _uploadFeaturedPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || storeId == null) return;

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_featured.php'))
      ..fields['store_id'] = storeId!
      ..files.add(await http.MultipartFile.fromPath('featured', image.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final result = json.decode(respStr);

    if (result['success']) {
      setState(() => featuredPhotos.add(result['url']));
      _showSnackBar("Featured photo uploaded.");
    } else {
      _showSnackBar(result['message']);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile'), centerTitle: true),
      body: isLoading
          ? _buildShimmer()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _logoCard(),
                  const SizedBox(height: 20),
                  _featuredPhotoCard(),
                  const SizedBox(height: 20),
                  _buildTextField('Business Name', businessNameController),
                  _buildTextField('Category', categoryController),
                  _buildTextField('Description', descriptionController, maxLines: 3),
                  _buildTextField('Email', emailController),
                  _buildTextField('Phone Number', phoneController),
                  _buildTextField('Partnership Type', partnershipController),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                    onPressed: _updateStore,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _logoCard() {
    return Column(
      children: [
        isUploadingLogo
            ? Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const CircleAvatar(radius: 80, backgroundColor: Colors.white),
              )
            : GestureDetector(
                onTap: _uploadLogo,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: businessLogoUrl != null
                      ? NetworkImage(businessLogoUrl!)
                      : const AssetImage('assets/images/default_store.png') as ImageProvider,
                ),
              ),
        const SizedBox(height: 8),
        const Text("Tap logo to change")
      ],
    );
  }

  Widget _featuredPhotoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("⭐ Featured Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: _uploadFeaturedPhoto, icon: const Icon(Icons.add_a_photo)),
          ],
        ),
        const SizedBox(height: 12),
        featuredPhotos.isEmpty
            ? const Text("No featured photos uploaded.")
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredPhotos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(featuredPhotos[index], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),
                ),
              )
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.all(12),
          child: Container(height: 80, color: Colors.white),
        ),
      ),
    );
  }
}
