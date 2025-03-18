import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/services/auth_service.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:logger/logger.dart';

class ChatHomeScreen extends StatefulWidget {
  static const String routeName = '/chathome';

  const ChatHomeScreen({super.key});

  @override
  ChatHomeScreenState createState() => ChatHomeScreenState();
}

class ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const routeName = '/chathome';

  // Function to start a new chat with a randomly matched user
  void _startNewChat(BuildContext context) async {
    final logger = Logger(); // Initialize Logger
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      logger.e("No user is logged in.");
      return;
    }

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);
    DocumentSnapshot currentUserDoc = await currentUserRef.get();

    if (currentUserDoc.exists) {
      bool isMatchable = currentUserDoc["matchable"] ?? false;

      // If user is not matchable, reset them so they can be matched again
      if (!isMatchable) {
        logger.w("User was not matchable, resetting...");
        await currentUserRef.update({
          "matchable": true,
        });
      }
    }

    logger.w("Searching for available users...");
    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('matchable', isEqualTo: true)
        .where('uid', isNotEqualTo: currentUser.uid) // Exclude current user
        .limit(1)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      logger.w("No available users for matching.");
      return;
    }

    String matchedUserUid = usersSnapshot.docs.first['uid'];
    DocumentReference matchedUserRef =
        _firestore.collection('users').doc(usersSnapshot.docs.first.id);

    logger.i("Matched user found: $matchedUserUid");

    DocumentSnapshot matchedUserDoc = await matchedUserRef.get();
    if (!matchedUserDoc.exists) {
      logger.e("Error: Matched user document does not exist.");
      return;
    }

      var newChatRef = _firestore.collection('chats').doc();
      await newChatRef.set({
        "participants": [currentUser.uid, matchedUserUid],
        "createdAt": FieldValue.serverTimestamp(),
        "chatStatus": "active"
      });

      logger.i("✅ New chat created: ${newChatRef.id}");

      // 🔹 Step 3: Assign both users to the same chat
      await currentUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});

      await matchedUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});

    logger.i("Chat successfully created! Navigating to chat screen...");
    
if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: newChatRef.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForMatch) {
      return WaitingForMatchScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/HomeScreen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
              onTap: () async {
                await _startNewChat(context);
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
        ],
      ),
    );
  }
}
