import 'package:flutter/material.dart';
import 'package:gemo/auth_service.dart';

class ChatHomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ChatHomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 290),
              child: Text(
                'Let’s Chat!',
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 62,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 50,
            child: IconButton(
              icon: const Icon(Icons.logout, size: 30, color: Colors.black),
              onPressed: () => _signOut(context),
            ),
          ),
        ],
      ),
    );
  }
}
