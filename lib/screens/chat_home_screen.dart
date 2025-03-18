import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:gemo/screens/categories_screen.dart'; // ✅ Updated to CategoriesScreen

class ChatHomeScreen extends StatefulWidget {
  static const String routeName = '/chathome';

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentChatId;
  bool _waitingForMatch = false;

  void _startNewChat() async {
    setState(() {
      _waitingForMatch = true; // Show waiting screen
    });

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("🚨 ERROR: No user is logged in.");
      return;
    }

    DocumentReference queueRef = _firestore.collection('chat_queue').doc('waiting_user');
    DocumentSnapshot queueDoc = await queueRef.get();

    if (queueDoc.exists && queueDoc['uid'] != currentUser.uid) {
      String matchedUserUid = queueDoc['uid'];
      var newChatRef = _firestore.collection('chats').doc();

      await newChatRef.set({
        "participants": [currentUser.uid, matchedUserUid],
        "createdAt": FieldValue.serverTimestamp(),
        "chatStatus": "active"
      });

      print("✅ New chat created: ${newChatRef.id}");

      await _firestore.collection('users').doc(currentUser.uid).update({
        "currentChat": newChatRef.id,
        "matchable": false
      });

      await _firestore.collection('users').doc(matchedUserUid).update({
        "currentChat": newChatRef.id,
        "matchable": false
      });

      await queueRef.delete();
    } else {
      print("🔄 No match found, adding user to queue...");
      await queueRef.set({"uid": currentUser.uid});
    }

    _listenForChatUpdates();
  }

  void _listenForChatUpdates() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _firestore.collection('users').doc(currentUser.uid).snapshots().listen((doc) {
      if (doc.exists && doc.data()?['currentChat'] != null) {
        String chatId = doc.data()?['currentChat'];
        if (chatId.isNotEmpty && chatId != _currentChatId) {
          _currentChatId = chatId;
          _waitingForMatch = false; // Hide waiting screen
          _navigateToChatScreen(chatId);
        }
      }
    });
  }

  void _navigateToChatScreen(String chatId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
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
            decoration: BoxDecoration(
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
          // New Chat Button
          Positioned(
            left: 78,
            top: 405,
            child: GestureDetector(
              onTap: _startNewChat,
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
          // Browse Categories Button (Smaller & Light Gray)
          Positioned(
            left: 120, // Centered below "New Chat"
            top: 510, // Below "New Chat" button
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()), // ✅ Corrected navigation
                );
              },
              child: Container(
                width: 180,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // ✅ Light gray background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Browse Categories',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
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
