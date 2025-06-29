import 'dart:convert';
import 'package:corridle/Store_Dashboard/appbar/ads.dart';
import 'package:corridle/Store_Dashboard/appbar/home_main.dart';
import 'package:corridle/Store_Dashboard/appbar/message.dart';
import 'package:corridle/Store_Dashboard/appbar/notification.dart';
import 'package:corridle/Store_Dashboard/appbar/post_performance.dart';
import 'package:corridle/Store_Dashboard/appbar/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'analytics.dart';
import 'feedback.dart';
import 'dashboard.dart';
import 'post.dart';
import 'schedule.dart';
import 'setting.dart';
import 'review.dart';

class ShopownerDashboard extends StatefulWidget {
  final String userUid;

  const ShopownerDashboard({Key? key, required this.userUid}) : super(key: key);

  @override
  State<ShopownerDashboard> createState() => _ShopownerDashboardState();
}

class _ShopownerDashboardState extends State<ShopownerDashboard> {
  String _selectedScreen = 'DashBoard';
  String _homeSubScreen = 'Home';
  bool _isSidebarOpen = false;

  String storeName = 'Store Name';
  String businessLogo = '';

  @override
  void initState() {
    super.initState();
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    final response = await http.post(
      Uri.parse('https://yourdomain.com/api/get_store.php'),
      body: {'user_uid': widget.userUid},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          storeName = data['store']['business_name'] ?? 'Store Name';
          businessLogo = data['store']['business_logo'] ?? '';
        });
      }
    }
  }

  final Map<String, Widget> _screens = {
    'DashBoard': const dashScreen(),
    'Reviews': const ReviewScreen(),
    'Posts': const PostScreen(),
    'Analytics': const AnalyticsScreen(),
    'Team Schedule': const ScheduleScreen(),
    'Settings': const SettingScreen(),
    'Feedback': const FeedbackScreen(),
    'Home': const HomeMainScreen(),
    'My Business': const dashScreen(),
    'Notifications': const Notificationscreen(),
    'Messages & Request': const MessageScreen(),
  };

  final Set<String> _appBarScreens = {
    'Home',
    'My Business',
    'Notifications',
    'Messages & Request',
  };

  void _changeScreen(String screenName) {
    setState(() {
      _selectedScreen = screenName;
      if (screenName != 'Home') _homeSubScreen = 'Home';
    });
  }

  Widget _buildMainContent() {
    if (_selectedScreen != 'Home') {
      return _screens[_selectedScreen] ?? const Center(child: Text('Screen not found'));
    }

    switch (_homeSubScreen) {
      case 'Home':
        return const HomeMainScreen();
      case 'Profile':
        return const ProfileScreen();
      case 'Analytics':
        return const AnalyticsScreen();
      case 'Create an ad':
        return const adsScreen();
      default:
        return const HomeMainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: isMobile && !_isSidebarOpen
          ? Drawer(child: _buildSidebarContent(isMobile: true))
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              isMobile
                  ? Icons.menu
                  : (_isSidebarOpen ? Icons.chevron_left : Icons.menu),
              color: Colors.black,
            ),
            onPressed: () {
              if (isMobile) {
                Scaffold.of(context).openDrawer();
              } else {
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              }
            },
          ),
        ),
        title: Row(
          children: [
            if (!isMobile)
              const Text("Corridle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (!isMobile)
            Row(
              children: [
                _navChip('Home', onTap: () => _changeScreen('Home'), selected: _selectedScreen == 'Home'),
                _navChip('My Business', onTap: () => _changeScreen('DashBoard'), selected: _selectedScreen == 'DashBoard'),
                _navChip('Notifications', onTap: () => _changeScreen('Notifications'), selected: _selectedScreen == 'Notifications'),
                _navChip('Messages & Request', onTap: () => _changeScreen('Messages & Request'), selected: _selectedScreen == 'Messages & Request'),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 8),
            child: businessLogo.isNotEmpty
                ? CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(businessLogo),
                    backgroundColor: Colors.grey.shade200,
                  )
                : const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: (!isMobile && _isSidebarOpen) ? 220 : 0,
            color: Colors.white,
            child: _isSidebarOpen || isMobile ? _buildSidebarContent(isMobile: false) : null,
          ),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMainContent(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Terms of Use   Privacy Policy   Support\n© Corridle 2025',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent({required bool isMobile}) {
    final homeItems = ['Home', 'Profile', 'Analytics', 'Post Performance', 'Create an ad'];
    final generalItems = _screens.keys
        .where((key) => !_appBarScreens.contains(key) && key != 'Home')
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          businessLogo.isNotEmpty
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(businessLogo),
                  backgroundColor: Colors.grey.shade200,
                )
              : const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.store, color: Colors.white, size: 40),
                ),
          const SizedBox(height: 12),
          Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const Text('Web application services', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 20),
          ...(_selectedScreen == 'Home'
              ? homeItems.map((label) => _sidebarButton(label, _homeSubScreen == label, isHomeSub: true)).toList()
              : generalItems.map((label) => _sidebarButton(label, _selectedScreen == label)).toList()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarButton(String label, bool selected, {bool isHomeSub = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_selectedScreen == 'Home' && isHomeSub) {
              _homeSubScreen = label;
            } else {
              _changeScreen(label);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.lightBlueAccent : Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _navChip(String label, {bool selected = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
