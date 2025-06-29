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
    // fetchPosts();
  }

  // Future<void> fetchPosts() async {
  //   final response = await http.get(Uri.parse(''));

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data['success'] == true) {
  //       setState(() {
  //         posts = data['posts'] ?? [];
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() => isLoading = false);
  //     }
  //   } else {
  //     print("Error: ${response.body}");
  //     setState(() => isLoading = false);
  //   }
  // }

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
                      final description = post['description']?.toString() ?? 'No description';

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
                              Container(
                                width: double.infinity,
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Business Logo / Image Placeholder',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
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
