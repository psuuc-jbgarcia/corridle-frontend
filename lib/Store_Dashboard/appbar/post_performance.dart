import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class postScreen extends StatefulWidget {
  const postScreen({Key? key}) : super(key: key);

  @override
  State<postScreen> createState() => _postScreenState();
}

class _postScreenState extends State<postScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text('Post Performance'),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .where('user_uid', isEqualTo: currentUid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final views = data['views'] ?? 0;
              final likes = data['likes'] ?? 0;
              final shares = data['shares'] ?? 0;
              final comments = data['comments'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('Views', style: TextStyle(fontSize: 10));
                                      case 1:
                                        return const Text('Likes', style: TextStyle(fontSize: 10));
                                      case 2:
                                        return const Text('Shares', style: TextStyle(fontSize: 10));
                                      case 3:
                                        return const Text('Comments', style: TextStyle(fontSize: 10));
                                      default:
                                        return const Text('');
                                    }
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [
                                BarChartRodData(toY: views.toDouble(), color: Colors.blue, width: 16)
                              ]),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(toY: likes.toDouble(), color: Colors.green, width: 16)
                              ]),
                              BarChartGroupData(x: 2, barRods: [
                                BarChartRodData(toY: shares.toDouble(), color: Colors.orange, width: 16)
                              ]),
                              BarChartGroupData(x: 3, barRods: [
                                BarChartRodData(toY: comments.toDouble(), color: Colors.red, width: 16)
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
