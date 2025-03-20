import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:gemo/screens/categories_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _resetChatOnStartup(); // ✅ Reset chat state on app start
  }

  void _resetChatOnStartup() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);
    DocumentReference queueRef =
        _firestore.collection('chat_queue').doc('waiting_user');

    // ✅ Remove user from the queue on app startup to avoid stale entries
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot queueSnapshot = await transaction.get(queueRef);
      if (queueSnapshot.exists && queueSnapshot['uid'] == currentUser.uid) {
        transaction.delete(queueRef);
        print("🗑 Removed stale queue entry for user ${currentUser.uid}");
      }
    });

    // ✅ Reset chat state for proper matching
    await currentUserRef.update({
      "currentChat": null,
      "matchable": true,
    });

    print("🔄 Reset chat state on app start.");
  }

  Future<void> _matchUsers(String user1Uid, String user2Uid,
      DocumentReference queueRef, DocumentReference user1Ref) async {
    DocumentReference user2Ref = _firestore.collection('users').doc(user2Uid);
    DocumentSnapshot user2Doc = await user2Ref.get();

    // ✅ Ensure user2 is still active and matchable before proceeding
    if (!user2Doc.exists ||
        user2Doc['matchable'] == false ||
        user2Doc['currentChat'] != null) {
      print(
          "🚨 User $user2Uid is no longer available for matching. Removing from queue...");
      await queueRef.delete();
      return;
    }

    var newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      "participants": [user1Uid, user2Uid],
      "createdAt": FieldValue.serverTimestamp(),
      "chatStatus": "active"
    });

    print("✅ New chat created: ${newChatRef.id}");

    // Update both users' chat references
    await user1Ref.update({"currentChat": newChatRef.id, "matchable": false});
    await user2Ref.update({"currentChat": newChatRef.id, "matchable": false});

    // Remove from queue
    await queueRef.delete();
  }

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
    DocumentReference queueRef =
        _firestore.collection('chat_queue').doc('waiting_user');

    // ✅ Remove old queue entries before adding a new user
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot queueSnapshot = await transaction.get(queueRef);
      if (queueSnapshot.exists) {
        String queuedUserId = queueSnapshot['uid'];
        DocumentSnapshot queuedUserDoc =
            await _firestore.collection('users').doc(queuedUserId).get();

        if (!queuedUserDoc.exists ||
            queuedUserDoc['matchable'] == false ||
            queuedUserDoc['currentChat'] != null) {
          transaction.delete(queueRef); // Remove stale queue entry
          print("🗑 Removed stale user from queue: $queuedUserId");
        }
      }
    });

    // 🔹 Step 1: Reset user's chat state
    await currentUserRef.update({"currentChat": null, "matchable": true});

    // 🔹 Step 2: Check for a match again
    DocumentSnapshot queueDoc = await queueRef.get();
    if (queueDoc.exists && queueDoc['uid'] != currentUser.uid) {
      // Match found, create chat
      await _matchUsers(
          currentUser.uid, queueDoc['uid'], queueRef, currentUserRef);
    } else {
      // No match found, force user into queue
      await queueRef.set({"uid": currentUser.uid});
      print("🔄 No match found, user added to queue.");
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
      if (doc.exists) {
        String? chatId = doc.data()?['currentChat'];

        if (chatId != null && chatId.isNotEmpty) {
          if (chatId != _currentChatId) {
            setState(() {
              _currentChatId = chatId;
              _waitingForMatch = false; // Hide waiting screen properly
            });

            _navigateToChatScreen(chatId);
          }
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
          // Browse Categories Button
          Positioned(
            left: 120, // Centered below "New Chat"
            top: 510, // Below "New Chat" button
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CategoriesScreen()), // ✅ Navigate correctly
                );
              },
              child: Container(
                width: 180,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Light gray background
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
