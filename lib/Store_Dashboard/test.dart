import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopOwnerTestScreen extends StatefulWidget {
  const ShopOwnerTestScreen({Key? key}) : super(key: key);

  @override
  State<ShopOwnerTestScreen> createState() => _ShopOwnerTestScreenState();
}

class _ShopOwnerTestScreenState extends State<ShopOwnerTestScreen> {
  String userId = '';
  String email = '';
  String storeId = '';

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      storeId = prefs.getString('store_id') ?? 'N/A';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Owner Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Shop Owner Test Screen', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text('User ID: $userId', style: const TextStyle(fontSize: 16)),
            Text('Email: $email', style: const TextStyle(fontSize: 16)),
            Text('Store ID: $storeId', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
