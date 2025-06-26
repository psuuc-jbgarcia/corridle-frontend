import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStatus = "Available";
  File? _image;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submitPost() async {
    if (_image == null || _descriptionController.text.isEmpty) return;

    setState(() => isLoading = true);
    final uri = Uri.parse('https://yourdomain.com/api/upload_post.php');

    var request = http.MultipartRequest('POST', uri);
    request.fields['description'] = _descriptionController.text;
    request.fields['status'] = _selectedStatus;

    final mimeTypeData = lookupMimeType(_image!.path)!.split('/');
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _image!.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    ));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final result = response.statusCode == 200;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text(result ? 'Post submitted successfully!' : 'Failed to submit post'),
        backgroundColor: result ? Colors.green : Colors.red,
      ),
    );

    if (result) {
      setState(() {
        _image = null;
        _descriptionController.clear();
        _selectedStatus = "Available";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Image", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.add_photo_alternate, size: 50))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Enter your product or service description...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ["Available", "Sold"].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitPost,
                  icon: const Icon(Icons.upload_file),
                  label: Text(isLoading ? 'Submitting...' : 'Submit Post'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
