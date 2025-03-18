import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';

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

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);

    // 🔹 Step 1: Reset old chat before searching for a match
    await currentUserRef.update({"currentChat": null, "matchable": true});

    print("🔄 Reset current user’s chat status.");

    DocumentReference queueRef =
        _firestore.collection('chat_queue').doc('waiting_user');
    DocumentSnapshot queueDoc = await queueRef.get();

    if (queueDoc.exists && queueDoc['uid'] != currentUser.uid) {
      // 🔹 Step 2: A match is found; create a new chat
      String matchedUserUid = queueDoc['uid'];
      DocumentReference matchedUserRef =
          _firestore.collection('users').doc(matchedUserUid);

      var newChatRef = _firestore.collection('chats').doc();
      await newChatRef.set({
        "participants": [currentUser.uid, matchedUserUid],
        "createdAt": FieldValue.serverTimestamp(),
        "chatStatus": "active"
      });

      print("✅ New chat created: ${newChatRef.id}");

      // 🔹 Step 3: Assign both users to the same chat
      await currentUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});

      await matchedUserRef
          .update({"currentChat": newChatRef.id, "matchable": false});

      // 🔹 Step 4: Remove the waiting user from the queue
      await queueRef.delete();

      print("🔄 Match complete! Both users are in the same chat.");
    } else {
      // 🔹 No available match; add the user to the queue
      print("🔄 No match found, adding user to queue...");
      await queueRef.set({"uid": currentUser.uid});
    }

    _listenForChatUpdates();
  }

  void _listenForChatUpdates() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .listen((doc) {
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
        ],
      ),
    );
  }
}
