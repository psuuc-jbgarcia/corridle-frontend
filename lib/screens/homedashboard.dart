import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:corridle/authentication/login.dart';
import 'package:corridle/authentication/sign_up.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 110, 190, 255),
        elevation: 0,
        title: Image.asset(
          'assets/images/Logo.jpg',
          height: 40,
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: Text("Login", style: GoogleFonts.poppins(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
            },
            child: Text("Sign Up", style: GoogleFonts.poppins(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Image.asset('assets/images/landing_page.png', fit: BoxFit.cover),
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        "Find local community run businesses.",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 14, 14, 14),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 400,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 166, 202, 252),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your Zipcode',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Icon(Icons.search, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            _sectionTitle("Featured businesses"),
            _horizontalCardList(),
            SizedBox(height: 20),
            _sectionTitle("Who we are?"),
            _largeGreyBox(),
            SizedBox(height: 20),
            _signupBox(),
            SizedBox(height: 20),
            _sectionTitle("What everyone is saying:"),
            _testimonialClouds(),
            SizedBox(height: 20),
            _sectionTitle("Are you a business owner?"),
            _largeGreyBox(),
            SizedBox(height: 20),
            _sectionTitle("Are you looking for jobs?"),
            _largeGreyBox(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _horizontalCardList() {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          width: 120,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _largeGreyBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _signupBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFdff5fd),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Community, Your Network — Join Corridle Today.",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email address',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Zip code',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              onPressed: () {},
              child: Text("Continue", style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _testimonialClouds() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          10,
          (index) => Container(
            width: 80 + (index % 3) * 30,
            height: 40 + (index % 2) * 20,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
