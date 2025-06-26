import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class dashScreen extends StatefulWidget {
  const dashScreen({Key? key}) : super(key: key);

  @override
  State<dashScreen> createState() => _dashScreenState();
}

class _dashScreenState extends State<dashScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('https://yourdomain.com/api/get_posts.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          posts = data['posts'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      print("Error: ${response.body}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : posts.isEmpty
                ? const Center(
                    child: Text(
                      'No posts available.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final description = post['description'] ?? 'No description';
                      final imageUrl = post['image_url'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12.0)),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      print("Image error: $error");
                                      return const SizedBox(
                                        height: 250,
                                        child: Center(child: Text('Failed to load image')),
                                      );
                                    },
                                  ),
                                )
                              else
                                const SizedBox(
                                  height: 250,
                                  child: Center(child: Text('No Image Available')),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const Divider(thickness: 1, color: Colors.grey, height: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
