import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardTest extends StatefulWidget {
  const UserDashboardTest({super.key});

  @override
  State<UserDashboardTest> createState() => _UserDashboardTestState();
}

class _UserDashboardTestState extends State<UserDashboardTest> {
  String userId = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'Not Found';
      email = prefs.getString('email') ?? 'Not Found';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: $userId'),
            Text('Email: $email'),
          ],
        ),
      ),
    );
  }
}
