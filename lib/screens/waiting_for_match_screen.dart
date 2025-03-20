import 'package:flutter/material.dart';

import 'chat_home_screen.dart';

class WaitingForMatchScreen extends StatelessWidget {
  const WaitingForMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Looking for a match...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHomeScreen()),
                );
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
