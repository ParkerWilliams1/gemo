import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:gemo/screens/my_chats_screen.dart'; // Import MyChatsScreen
import 'package:gemo/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:gemo/screens/settings_screen.dart'; // Import SettingsScreen

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.groups_outlined,
              label: 'My Chats',
              onPressed: () {
                Logger("Navigating to My Chats...");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyChatsScreen()),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.person_outline_outlined,
              label: 'Profile',
              onPressed: () {
                Logger("Navigating to Profile...");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(
                      firstName: "Grace",
                      lastName: "Bergquist",
                      major: "Computer Science",
                      subjects: "Math, Physics",
                      username: "graceb",
                      email: "grace@example.com",
                      password: "password123",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onPressed: () {
                Logger("Navigating to Settings...");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              icon: Icons.logout,
              label: 'Logout',
              onPressed: () {}, // Implement logout function here
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
