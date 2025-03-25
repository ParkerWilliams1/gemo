import 'package:flutter/material.dart';
import 'package:gemo/services/matchmaking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class WaitingForMatchScreen extends StatefulWidget {
  static const String routeName = '/waitingformatch';

  const WaitingForMatchScreen({super.key}); // Removed the onCancel parameter

  @override
  State<WaitingForMatchScreen> createState() => WaitingForMatchScreenState();
}

class WaitingForMatchScreenState extends State<WaitingForMatchScreen> {
  final MatchmakingService _matchmakingService = MatchmakingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger(); // Initialize the logger

  @override
  void initState() {
    super.initState();
    _logger.i("WaitingForMatchScreen initialized.");
    _joinQueue();
  }

  void _joinQueue() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _logger.i("User ${user.uid} is joining the queue.");
      _matchmakingService.joinQueue(user.uid, 'chat_queue');
      _logger.i("User ${user.uid} successfully joined the queue.");
    } else {
      _logger.w("No user is logged in. Cannot join the queue.");
    }
  }

  void _leaveQueue() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _logger.i("User ${user.uid} is leaving the queue.");
      _matchmakingService.leaveQueue(user.uid);
      _logger.i("User ${user.uid} successfully left the queue.");
    } else {
      _logger.w("No user is logged in. Cannot leave the queue.");
    }
  }

   @override
  void dispose() {
    _logger.i("WaitingForMatchScreen is being disposed.");
    _leaveQueue(); // Ensure the user leaves the queue when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.i("Building WaitingForMatchScreen UI.");
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
                _logger.i("Cancel button pressed. Navigating back.");
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