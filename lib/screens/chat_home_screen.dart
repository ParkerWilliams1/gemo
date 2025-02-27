import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/auth_service.dart';
import 'package:gemo/screens/text_chat_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatHomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await _authService.signOut();
  }

  // Function to start a new chat with a randomly matched user
  void _startNewChat(BuildContext context) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("No user is logged in.");
      return;
    }

    print("Current user ID: ${currentUser.uid}");

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);
    DocumentSnapshot currentUserDoc = await currentUserRef.get();

    // Ensure the current user document exists
    if (!currentUserDoc.exists) {
      print("Current user document does not exist. Creating...");
      await currentUserRef.set({
        "uid": currentUser.uid,
        "email": currentUser.email,
        "matchable": true,
        "currentChat": null,
        "schoolDomain": currentUser.email!.split('@').last,
        "createdAt": FieldValue.serverTimestamp(),
      });
      print("User document created.");
    } else {
      print("Current user document exists.");
    }

    // Find another matchable user
    print("Searching for available users...");
    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('matchable', isEqualTo: true)
        .where('uid', isNotEqualTo: currentUser.uid) // Exclude current user
        .limit(1)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      print("No available users for matching.");
      return;
    }

    // Instead of using `uid`, use Firestore's actual document ID
    DocumentSnapshot matchedUserDoc = usersSnapshot.docs.first;
    String matchedUserFirestoreId = matchedUserDoc.id; // Firestore document ID
    String matchedUserUid =
        matchedUserDoc['uid'].toString(); // User's actual UID

    print(
        "Matched user found: Firestore ID = $matchedUserFirestoreId, UID = $matchedUserUid");

    DocumentReference matchedUserRef =
        _firestore.collection('users').doc(matchedUserFirestoreId);
    DocumentSnapshot matchedUserExistsCheck = await matchedUserRef.get();

    if (!matchedUserExistsCheck.exists) {
      print("Error: Matched user document does not exist in Firestore.");
      return;
    }

    // Create a new chat
    var newChatRef = _firestore.collection('chats').doc();
    print("Creating new chat with ID: ${newChatRef.id}");

    await newChatRef.set({
      "participants": [
        currentUser.uid,
        matchedUserUid
      ], // Store actual UID, not Firestore ID
      "createdAt": FieldValue.serverTimestamp(),
      "chatStatus": "active"
    });

    // Update users' chat status
    print("Updating users' chat status...");
    await currentUserRef
        .update({"currentChat": newChatRef.id, "matchable": false});

    await matchedUserRef
        .update({"currentChat": newChatRef.id, "matchable": false});

    print("Chat successfully created! Navigating to chat screen...");

    // Navigate to the new chat
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: newChatRef.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
    );
  }
}
