import 'package:flutter/material.dart';
import 'package:gemo/services/auth_service.dart';

class ChatHomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ChatHomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/HomeScreen.png'), // Background Image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
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
              left: 78,
              top: 405,
              child: GestureDetector(
                onTap: () {
                  print("New Chat Clicked");
                },
                child: Container(
                  width: 247,
                  height: 91,
                  decoration: BoxDecoration(
                    color: const Color(0xFF83B9FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'New Chat',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 105,
              top: 527,
              child: GestureDetector(
                onTap: () {
                  print("Browse Categories Clicked");
                },
                child: Container(
                  width: 200,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(width: 1, color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Browse Categories',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.chevron_right,
                            size: 24, color: Color(0xFF707070)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 78 + 247 - 30 - 16,
              top: 405 + (91 - 30) / 2,
              child: Icon(Icons.chevron_right, size: 30, color: Colors.black),
            ),
            Positioned(
              left: -36,
              top: -33,
              child: Container(
                width: 473,
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(width: 1, color: Colors.white),
                ),
              ),
            ),
            // const Positioned(
            //   left: 325,
            //   top: 37,
            //   child: Icon(Icons.settings, size: 48, color: Colors.grey),
            // ),
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
      ),
    );
  }
}