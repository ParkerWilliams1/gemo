import 'dart:async';

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
  late StreamSubscription<DocumentSnapshot> _chatSubscription;

  @override
  void initState() {
    super.initState();
    _resetChatOnStartup();
  }

  @override
  void dispose() {
    _chatSubscription
        .cancel(); // ✅ Cancel stream to avoid setState after dispose
    super.dispose();
  }

  void _resetChatOnStartup() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);
    DocumentReference queueRef =
        _firestore.collection('chat_queue').doc(currentUser.uid);

    await queueRef.delete().catchError((e) {
      print("ℹ️ No existing queue entry for cleanup.");
    });

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

  Future<void> startNewChatSafely() async {
    setState(() {
      _waitingForMatch = true;
    });

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("🚨 ERROR: No user is logged in.");
      return;
    }

    final String currentUid = currentUser.uid;
    final userRef = _firestore.collection('users').doc(currentUid);
    final queueRef = _firestore.collection('chat_queue').doc(currentUid);

    // Step 1: Clean up any stale queue entry for the current user
    try {
      await queueRef.delete();
      print("🧹 Cleared old queue entry for $currentUid.");
    } catch (e) {
      print("ℹ️ No previous queue entry to delete for $currentUid.");
    }

    // Step 2: Search for another user in the queue (excluding current user)
    try {
      final snapshot = await _firestore
          .collection('chat_queue')
          .where('uid', isNotEqualTo: currentUid)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final matchedDoc = snapshot.docs.first;
        final matchedData = matchedDoc.data() as Map<String, dynamic>?;

        if (matchedData == null ||
            matchedData['uid'] == null ||
            matchedData['uid'].toString().isEmpty) {
          print("❌ ERROR: Matched document missing 'uid' field.");
          return;
        }

        final String matchedUid = matchedData['uid'];
        print("🎯 Match found! Matched with user $matchedUid");

        final matchedUserRef = _firestore.collection('users').doc(matchedUid);
        final matchedQueueRef =
            _firestore.collection('chat_queue').doc(matchedUid);

        // Step 3: Create a new chat
        final newChatRef = _firestore.collection('chats').doc();
        await newChatRef.set({
          'participants': [currentUid, matchedUid],
          'createdAt': FieldValue.serverTimestamp(),
          'chatStatus': 'active',
        });

        // Step 4: Update both users' chat references
        await userRef
            .update({'currentChat': newChatRef.id, 'matchable': false});
        await matchedUserRef
            .update({'currentChat': newChatRef.id, 'matchable': false});

        // Step 5: Clean up queue entries
        await queueRef.delete();
        await matchedQueueRef.delete();

        print(
            "✅ Chat created between $currentUid and $matchedUid. Chat ID: ${newChatRef.id}");

        _listenForChatUpdates();
      } else {
        // No match found — add current user to queue
        print("📥 No match found. Adding $currentUid to queue...");

        try {
          await queueRef.set({
            'uid': currentUid,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print("✅ Successfully added $currentUid to chat_queue.");
        } catch (e) {
          print("🚨 Failed to add user to chat_queue: $e");
        }

        print("✅ User $currentUid added to chat_queue.");
        _listenForChatUpdates();
      }
    } catch (e) {
      print("🚨 Firestore error during matchmaking: $e");
    }
  }

  void _navigateToChatScreen(String chatId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
    );
  }

  void _listenForChatUpdates() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _chatSubscription = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .listen((doc) {
      if (!mounted) return; // ✅ Check if widget is still in tree

      if (doc.exists) {
        String? chatId = doc.data()?['currentChat'];

        if (chatId != null && chatId.isNotEmpty && chatId != _currentChatId) {
          setState(() {
            _currentChatId = chatId;
            _waitingForMatch = false;
          });
          _navigateToChatScreen(chatId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForMatch) {
      return WaitingForMatchScreen(
        category: 'General',
        onCancel: () {
          setState(() => _waitingForMatch = false);
        },
      );
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
              onTap: startNewChatSafely,
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
