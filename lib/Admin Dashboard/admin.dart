import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('admin test'),
          automaticallyImplyLeading: false, // Remove back arrow from AppBar
        ),
        body: const Center(
          child: Text('Welcome to the admin Dashboard!'),
        ),
      ),
    );
  }
}
