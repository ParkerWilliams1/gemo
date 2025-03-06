import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/auth_service.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'chat_home_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ChatHomeScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
