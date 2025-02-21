import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/auth_service.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'chat_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSignUp = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ChatHomeScreen();
        } else {
          return showSignUp
              ? SignUpScreen(toggleScreen: () => setState(() => showSignUp = false))
              : SignInScreen(toggleScreen: () => setState(() => showSignUp = true));
        }
      },
    );
  }
}
