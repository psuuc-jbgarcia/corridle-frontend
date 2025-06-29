import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> analyticsData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchAnalytics();
  }

  // Future<void> fetchAnalytics() async {
  //   final response = await http.post(
  //     Uri.parse('https://yourdomain.com/api/get_analytics.php'),
  //     body: {
  //       'user_uid': 'your_user_uid_here', // replace dynamically if needed
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final result = json.decode(response.body);
  //     if (result['success'] == true) {
  //       setState(() {
  //         analyticsData = result['data'];
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     setState(() => isLoading = false);
  //     print('Failed to fetch analytics data');
  //   }
  // }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Analytics Dashboard',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildCard(
                      'Post Views',
                      analyticsData['post_views'].toString(),
                      Icons.visibility,
                      Colors.blueAccent,
                    ),
                    buildCard(
                      'Engagement',
                      analyticsData['engagement'].toString(),
                      Icons.thumb_up,
                      Colors.green,
                    ),
                    buildCard(
                      'Ad Clicks',
                      analyticsData['ad_clicks'].toString(),
                      Icons.campaign,
                      Colors.orange,
                    ),
                    buildCard(
                      'Followers',
                      analyticsData['followers'].toString(),
                      Icons.people,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
