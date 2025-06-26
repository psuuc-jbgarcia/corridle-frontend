import 'package:flutter/material.dart';

class adsScreen extends StatelessWidget {
  const adsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: const Color.fromARGB(
            255, 165, 165, 165), // Apply dark background color
        body: const Center(
          child: Text('Welcome to the ads Dashboard!'),
        ),
      ),
    );
  }
}
