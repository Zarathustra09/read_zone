import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_zone/main_pages/home_page.dart';

import '../auth/login_page.dart';

class AuthService{

  Future<void> signup({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the username to the user's profile
      await userCredential.user!.updateDisplayName(username);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      print(message);
    } catch (e) {
      print('An error occurred during signup. Please try again.');
      print('Error: $e'); // Print the error
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      print('Attempting to sign in with email: $email');
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        print('User signed in successfully: ${user.uid}');

        // Redirect to MatchingPage directly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } else {
        print('User is null after sign in');
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else if (e.code == 'too-many-requests') {
        message = 'Access to this account has been temporarily disabled due to many failed login attempts. Please try again later or reset your password.';
      }
      print('FirebaseAuthException: $message'); // Changed to print
    } catch (e) {
      print('Exception: An error occurred during sign in. Please try again.'); // Changed to print
    }
  }

  Future<void> signout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('An error occurred during sign out. Please try again.');
      print('Error: $e');
    }
  }



}