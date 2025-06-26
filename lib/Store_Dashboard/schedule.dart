import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('schedule test'),
          automaticallyImplyLeading: false, // Remove back arrow from AppBar
        ),
        body: const Center(
          child: Text('Welcome to the schedule Dashboard!'),
        ),
      ),
    );
  }
}
