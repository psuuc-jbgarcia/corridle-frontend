import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key, required String userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('store test'),
          automaticallyImplyLeading: false, // Remove back arrow from AppBar
        ),
        body: const Center(
          child: Text('Welcome to the store Dashboard!'),
        ),
      ),
    );
  }
}
