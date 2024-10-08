import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_zone/theme.dart'; // Import your theme
import 'package:read_zone/components/navbar.dart'; // Import your Navbar
import 'package:read_zone/main_pages/favorite_page.dart'; // Import FavoritePage
import 'package:read_zone/auth/login_page.dart'; // Import LoginPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        username = user!.displayName ?? 'No Username';
        email = user!.email ?? 'No Email';
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black, // Contrast with primaryColor
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.secondaryColor,
              child: Icon(
                Icons.person,
                size: 80,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: AppTheme.primaryColor,
              ),
              title: const Text(
                'Favorite Books',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 4, // Set index to 4 for the profile
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}