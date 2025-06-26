import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<DocumentSnapshot> fetchStoreData(String uid) {
    return FirebaseFirestore.instance
        .collection('store')
        .where('user_uid', isEqualTo: uid)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
  }

  Future<List<QueryDocumentSnapshot>> fetchPosts(String uid, {bool shared = false}) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('user_uid', isEqualTo: uid)
        .where('is_shared', isEqualTo: shared)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.blueGrey,
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: fetchStoreData(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(data['businessLogo'] ?? ''),
                          ),
                          const SizedBox(height: 12),
                          Text(data['business_name'] ?? 'No Name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(data['description'] ?? 'No description'),
                          const SizedBox(height: 8),
                          Text("Email: ${data['email']}"),
                          Text("Phone: ${data['phone_number']}"),
                          Text("Partnership: ${data['partnership_type']}"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Featured Photos
                  if (data['featuredPhotos'] != null && data['featuredPhotos'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Featured Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: data['featuredPhotos'].length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  data['featuredPhotos'][index],
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // My Posts
                  const Text("My Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: fetchPosts(uid, shared: false),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Text("No posts found.");
                      }

                      return Column(
                        children: snapshot.data!.map((doc) {
                          final post = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(post['title'] ?? 'Untitled'),
                            subtitle: Text("Views: ${post['views'] ?? 0} • Likes: ${post['likes'] ?? 0}"),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Shared Posts
                  const Text("Shared Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: fetchPosts(uid, shared: true),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Text("No shared posts.");
                      }

                      return Column(
                        children: snapshot.data!.map((doc) {
                          final post = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(post['title'] ?? 'Untitled'),
                            subtitle: Text("Views: ${post['views'] ?? 0} • Likes: ${post['likes'] ?? 0}"),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
