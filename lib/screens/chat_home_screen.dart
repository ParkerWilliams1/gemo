import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/auth_service.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/categories_screen.dart';
import 'package:gemo/screens/menu_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const routeName = '/chathome';

  ChatHomeScreen({super.key});

  // Function to start a new chat with a randomly matched user
  void _startNewChat(BuildContext context) async {
    try {
      // 🔹 Step 1: Verify Authentication
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("🚨 ERROR: No user is logged in.");
        return;
      }

      print("🔍 Searching for available users...");
      print("👤 Current user: ${currentUser.uid}");

      // 🔹 Step 2: Get Current User Data from Firestore
      DocumentReference currentUserRef =
          _firestore.collection('users').doc(currentUser.uid);
      DocumentSnapshot currentUserDoc = await currentUserRef.get();

      if (!currentUserDoc.exists) {
        print("🚨 ERROR: Current user document does not exist in Firestore.");
        return;
      }

      bool isMatchable = currentUserDoc["matchable"] ?? false;
      if (!isMatchable) {
        print("🔄 User was not matchable, resetting...");
        await currentUserRef.update({"matchable": true});
      }

      // 🔹 Step 3: Query for an Available Match
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('matchable', isEqualTo: true)
          .where('uid', isNotEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        print("❌ No available users for matching.");
        return;
      }

      // 🔹 Step 4: Select Matched User
      String matchedUserUid = usersSnapshot.docs.first['uid'];
      DocumentReference matchedUserRef =
          _firestore.collection('users').doc(matchedUserUid);

      print("✅ Matched user found: $matchedUserUid");

      DocumentSnapshot matchedUserDoc = await matchedUserRef.get();
      if (!matchedUserDoc.exists) {
        print("🚨 ERROR: Matched user document does not exist in Firestore.");
        return;
      }

      // 🔹 Step 5: Create a New Chat
      print(
          "🔥 Attempting to create chat for: ${currentUser.uid} & ${matchedUserUid}");
      var newChatRef = _firestore.collection('chats').doc();

      await newChatRef.set({
        "participants": [
          currentUser.uid,
          matchedUserUid
        ], // 🔹 Must include currentUser.uid
        "createdAt": FieldValue.serverTimestamp(),
        "chatStatus": "active"
      });

      print("✅ Chat successfully created: ${newChatRef.id}");

      // 🔹 Step 6: Update User Chat Status
      await currentUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});
      await matchedUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});

      print("🔄 Users updated to be in the new chat.");

      // 🔹 Step 7: Navigate to Chat Screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(chatId: newChatRef.id)),
      );
    } catch (e) {
      print("🚨 ERROR creating chat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/HomeScreen.png'),
                fit: BoxFit.cover,
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
            top: 510,
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
          // Menu Button
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
