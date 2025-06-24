import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  final String userUid;

  const UserDashboardScreen({Key? key, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.blue.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Corridle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _navItem('Home'),
                    _navItem('Orders'),
                    _navItem('Messages'),
                    _navItem('Settings'),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Replace with logout logic
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Welcome to Corridle Dashboard!\nYour ID is $userUid',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {
          // Add navigation logic here
        },
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
