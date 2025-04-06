import 'package:flutter/material.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Bar Background
          Positioned(
            left: -36,
            top: -33,
            child: Container(
              width: 473,
              height: 136,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            left: 20,
            top: 50,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Title: My Chats
          const Positioned(
            left: 137,
            top: 61,
            child: Text(
              'My Chats',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Recent Chats Section
          _sectionTitle("Recent Chats", 141),
          _chatBox(33, 196, "Hot Takes"),
          _chatBox(183, 196, "Basketball"),
          _chatBox(333, 196, "Calculus"),

          // Favorite Categories Section
          _sectionTitle("Favorite Categories", 324),
          _chatBox(33, 379, "Video Games"),
          _chatBox(183, 379, "Sports"),
          _chatBox(333, 379, "Chess"),

          // My Tutors Section
          _sectionTitle("My Tutors", 507),
          _tutorBox(33, 551, "Jeremy", "Physics"),
          _tutorBox(183, 551, "Sophia", "Calculus"),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _sectionTitle(String title, double top) {
    return Positioned(
      left: 23,
      top: top,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Chat Box Widget
  Widget _chatBox(double left, double top, String label) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 132,
            height: 102,
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Tutor Box Widget
  Widget _tutorBox(double left, double top, String name, String subject) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 132,
            height: 57,
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subject,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
