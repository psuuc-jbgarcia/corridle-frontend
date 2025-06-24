import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  final String userUid; // Step 1: Store the value

  const ShopScreen({Key? key, required this.userUid}) : super(key: key); // Step 2: Assign in constructor

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Store Test'),
          automaticallyImplyLeading: false, // Remove back arrow from AppBar
        ),
        body: Center(
          child: Text('Welcome, your user ID is $userUid'), // Step 3: Display it
        ),
      ),
    );
  }
}
