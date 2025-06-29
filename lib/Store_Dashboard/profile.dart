import 'package:flutter/material.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({Key? key}) : super(key: key);

  @override
  _StoreProfileScreenState createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final TextEditingController businessNameController = TextEditingController(text: 'Mock Business');
  final TextEditingController categoryController = TextEditingController(text: 'Retail');
  final TextEditingController descriptionController = TextEditingController(text: 'This is a mock description.');
  final TextEditingController emailController = TextEditingController(text: 'mock@example.com');
  final TextEditingController phoneController = TextEditingController(text: '09123456789');
  final TextEditingController partnershipController = TextEditingController(text: 'Solo');

  List<String> featuredPhotos = [
    'https://via.placeholder.com/100',
    'https://via.placeholder.com/100'
  ];
  String? businessLogoUrl = 'https://via.placeholder.com/150';

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Profile'), centerTitle: true),
      body: SingleChildScrollView(
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
              onPressed: () => _showSnackBar("Mock save successful."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoCard() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showSnackBar("Mock upload logo"),
          child: CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(businessLogoUrl!),
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
            IconButton(onPressed: () => _showSnackBar("Mock add photo"), icon: const Icon(Icons.add_a_photo)),
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
}
