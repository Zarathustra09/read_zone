import 'package:flutter/material.dart';
import 'package:read_zone/services/auth_service.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page', style: TextStyle(color: Colors.black)), // Black title color
        backgroundColor: Color(0xFFE0FBE2), // Use one of the colors from your palette
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              _authService.signout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Read Zone!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Explore your favorite books and authors.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // Black text color
              ),
            ),
            SizedBox(height: 40),

            // Example buttons for navigation
            ElevatedButton(
              onPressed: () {
                // Add your navigation logic here
              },
              child: Text('View Books', style: TextStyle(color: Colors.black)), // Black text color
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Add your navigation logic here
              },
              child: Text('My Profile', style: TextStyle(color: Colors.black)), // Black text color
            ),
          ],
        ),
      ),
    );
  }
}