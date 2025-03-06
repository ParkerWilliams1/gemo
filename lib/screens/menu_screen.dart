import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemo/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final AuthService _authService = AuthService(); // Instance of AuthService

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst); // Navigate back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black,
        title: Text(
          'Menu',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.groups_outlined,
              label: 'My Chats',
              onPressed: () {},
            ),
            SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.person_outline_outlined,
              label: 'Profile',
              onPressed: () {},
            ),
            SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onPressed: () {},
            ),
            SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.logout,
              label: 'Logout',
              onPressed: () => _signOut(context), // Calls the logout function
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 57, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }
}
