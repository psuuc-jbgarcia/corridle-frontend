import 'dart:convert';
import 'package:corridle/const_file/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:corridle/authentication/login.dart';
import 'package:corridle/Store_Dashboard/profile.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? businessName;
  String? businessLogo;

  @override
  void initState() {
    super.initState();
    fetchBusinessInfo();
  }

  Future<void> fetchBusinessInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storeId = prefs.getString('store_id') ?? '';

    if (storeId.isEmpty) {
      print("No store_id found in SharedPreferences.");
      return;
    }

    final url = Uri.parse("${logo_business_name}?store_id=$storeId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        final store = result['store'];
        setState(() {
          businessName = store['business_name'];
          businessLogo = store['business_logo']; // may be null
        });
      } else {
        print("Fetch failed: ${result['message']}");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = (businessLogo != null && businessLogo!.isNotEmpty)
        ? NetworkImage("http://192.168.100.177/backend/$businessLogo")
        : const AssetImage('assets/images/default_store.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreProfileScreen()));
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: imageWidget,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    businessName ?? 'Loading...',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreProfileScreen()));
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
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
