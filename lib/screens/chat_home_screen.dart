import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/services/auth_service.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/categories_screen.dart';
import 'package:gemo/screens/menu_screen.dart'; // Import MenuScreen
import 'package:logger/logger.dart'; // Import logger package

class ChatHomeScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const routeName = '/chathome';
  final Logger _logger = Logger(); // Initialize logger

  ChatHomeScreen({super.key});

  // Function to start a new chat with a randomly matched user
  void _startNewChat(BuildContext context) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _logger.w("No user is logged in.");
      return;
    }

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);
    DocumentSnapshot currentUserDoc = await currentUserRef.get();

    if (currentUserDoc.exists) {
      bool isMatchable = currentUserDoc["matchable"] ?? false;

      // If user is not matchable, reset them so they can be matched again
      if (!isMatchable) {
        _logger.w("User was not matchable, resetting...");
        await currentUserRef.update({
          "matchable": true,
        });
      }
    }

    _logger.w("Searching for available users...");
    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('matchable', isEqualTo: true)
        .where('uid', isNotEqualTo: currentUser.uid) // Exclude current user
        .limit(1)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      _logger.w("No available users for matching.");
      return;
    }

    String matchedUserUid = usersSnapshot.docs.first['uid'];
    DocumentReference matchedUserRef =
        _firestore.collection('users').doc(usersSnapshot.docs.first.id);

    _logger.w("Matched user found: $matchedUserUid");

    DocumentSnapshot matchedUserDoc = await matchedUserRef.get();
    if (!matchedUserDoc.exists) {
      _logger.w("Error: Matched user document does not exist.");
      return;
    }

    var newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      "participants": [
        currentUser.uid,
        matchedUserUid
      ], // Store actual UID, not Firestore ID
      "createdAt": FieldValue.serverTimestamp(),
      "chatStatus": "active"
    });

    await currentUserRef
        .update({"currentChat": newChatRef.id, "matchable": false});

    await matchedUserRef
        .update({"currentChat": newChatRef.id, "matchable": false});

    if (!context.mounted) return;
    _logger.i("Chat successfully created! Navigating to chat screen...");
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: newChatRef.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/HomeScreen.png'),
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
          ),
          // Chat text
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
          // New Chat Button
          Positioned(
            left: 78,
            top: 405,
            child: GestureDetector(
              onTap: () => _startNewChat(context),
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
          // Browse Categories Button
          Positioned(
            left: 78,
            top: 510, // Positioned below the "New Chat" button
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupsScreen()),
                );
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
                    'Browse Categories',
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
          // Menu Button (Replaces Logout Button)
          Positioned(
            right: 20,
            top: 50,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
