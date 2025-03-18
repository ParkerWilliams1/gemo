import 'package:flutter/material.dart';
import 'package:gemo/services/user_matching.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaitingForMatchScreen extends StatefulWidget {
  const WaitingForMatchScreen({super.key});
    @override
  State<WaitingForMatchScreen> createState() => WaitingForMatchScreenState();
}

class WaitingForMatchScreenState extends State<WaitingForMatchScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _joinQueue();
  }

  void _joinQueue() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _matchmakingService.joinQueue(user.uid);
    }
  }

  void _leaveQueue() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _matchmakingService.leaveQueue(user.uid);
    }
  }

  @override
  void dispose() {
    _leaveQueue(); // Ensure the user leaves the queue when the screen is disposed
    super.dispose();
  }

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
                Navigator.pop(context); // Let users cancel the search
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
