// import 'package:corridle/Store_Dashboard/businessdashboard.dart';
// import 'package:corridle/User_Dashboard/user_dasboard.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'screens/homedashboard.dart';
// import 'authentication/information.dart';
// import 'authentication/login.dart';
// import 'Admin Dashboard/admin.dart';
// import 'screens/customer.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Corridle',
//       theme: ThemeData(
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: UserDashboard(),
//       routes: {
//         '/customerscreen': (context) => const UserDashboardScreen(userUid: ''),
//         '/shopownerDashboard': (context) => const ShopownerDashboard(userUid: ''),
//         // '/signup': (context) => const InformationScreen(userUid: ''),
//         '/adminDashboard': (context) => const AdminScreen(),
//       },
//     );
//   }
// }

// /// Replace this with your PHP backend API URL
// const String apiUrl = "http://localhost/corridle_api/api.php";

// Future<void> submitUserType(String userType) async {
//   final response = await http.post(
//     Uri.parse(apiUrl),
//     body: {
//       'action': 'setUserType',
//       'user_uid': 'your_user_id_here',
//       'userType': userType,
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     print('Server response: $data');
//   } else {
//     print('Failed to submit user type. Code: ${response.statusCode}');
//   }
// }
import 'package:corridle/screens/homedashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Corridle',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LandingPage(), // Updated here
    );
  }
}

