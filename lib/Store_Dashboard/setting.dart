import 'dart:convert';
import 'dart:html' as html;
import 'package:corridle/Store_Dashboard/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:corridle/authentication/login.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Map<String, dynamic>? storeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    html.window.history.replaceState(null, 'Settings', '/settings');
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    // Replace with your logged-in user's UID passed from session/token
    final userUid = html.window.localStorage['user_uid'];

    final uri = Uri.parse('https://yourdomain.com/api/get_store_by_uid.php?user_uid=$userUid');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        setState(() {
          storeData = jsonData['store'];
          isLoading = false;
        });
      } else {
        print('Store not found');
        setState(() => isLoading = false);
      }
    } else {
      print('Failed to load store data');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear stored session if any
      html.window.localStorage.clear();
      html.window.location.href = 'https://pwaads-45ed9.web.app/';
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : storeData == null
                ? const Center(child: Text('No store data found.'))
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const StoreProfileScreen()),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      (storeData!['business_logo'] != null && storeData!['business_logo'].isNotEmpty)
                                          ? NetworkImage(storeData!['business_logo'])
                                          : const AssetImage('assets/images/default_store.png') as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                storeData!['business_name'] ?? 'Store Name',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StoreProfileScreen()),
                                  );
                                },
                                child: const Text('Edit Store Profile'),
                              ),
                              const Divider(height: 40, thickness: 1),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Privacy & Security'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
