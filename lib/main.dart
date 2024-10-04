import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:read_zone/main_pages/home_page.dart';
import 'package:read_zone/theme.dart';

import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: RegisterPage(),
    );
  }
}