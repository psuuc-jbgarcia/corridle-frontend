import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<dynamic> feedbackList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  Future<void> fetchFeedback() async {
    final response = await http.get(
      Uri.parse('https://yourdomain.com/api/get_feedback.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          feedbackList = data['feedback'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      print('Error fetching feedback: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Widget _buildFeedbackItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListTile(
          title: Text(item['name'] ?? 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item['message'] ?? 'No message'),
              const SizedBox(height: 8),
              Text(item['date'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Feedback'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : feedbackList.isEmpty
                ? const Center(
                    child: Text(
                      'No feedback yet.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) =>
                        _buildFeedbackItem(feedbackList[index]),
                  ),
      ),
    );
  }
}
