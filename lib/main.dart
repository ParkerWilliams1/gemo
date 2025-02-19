import 'package:flutter/material.dart';
import 'package:gemo/pages/login_or_register_page.dart';
// import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginOrRegisterPage(),
    );
  }
}