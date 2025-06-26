import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeMainScreen extends StatelessWidget {
  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDEBAR
           
            // MAIN CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Post Creator (placeholder)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Text("GEN", style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text("What's on your mind?"),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: postActionButton("Photo/Video")),
                                SizedBox(width: 10),
                                Expanded(child: postActionButton("Post")),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Posts Feed
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .orderBy('created_at', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No posts available."));
                          }

                          final posts = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              final data = post.data() as Map<String, dynamic>;

                              final firstName = data['firstName'] ?? '';
                              final lastName = data['lastName'] ?? '';
                              final fullName = "$firstName $lastName".trim();
                              final review = data['review_text'] ?? '';
                              final imageUrl = data['image_url'] ?? '';

                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          imageUrl.isNotEmpty
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(imageUrl),
                                                  radius: 20,
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  radius: 20,
                                                  child: Text(
                                                    fullName.isNotEmpty ? fullName[0] : '?',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                          SizedBox(width: 10),
                                          Text(
                                            fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(review),
                                      if (imageUrl.isNotEmpty) ...[
                                        SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.broken_image),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Like"),
                                          Text("Comment"),
                                          Text("Rate"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // RIGHT SIDEBAR
            Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Notifications"),
                          Divider(),
                          Text("Glenn Villanueva made a post on your business"),
                          Text("Lindsey Tanigue liked your post"),
                          Text("Danica Africano replied to your comment"),
                          TextButton(
                            onPressed: () {},
                            child: Text("See More"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network("https://via.placeholder.com/150x100"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title, style: TextStyle(fontSize: 14)),
      );

  Widget postActionButton(String title) => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
        ),
        child: Text(title),
      );
}
