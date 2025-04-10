import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:gemo/screens/categories_screen.dart';
import 'package:gemo/video_stream/join_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  static const String routeName = '/chathome';
  const ChatHomeScreen({super.key});

  @override
  ChatHomeScreenState createState() => ChatHomeScreenState();
}

class ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentChatId;
  bool _waitingForMatch = false;
  StreamSubscription<DocumentSnapshot>? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _resetChatOnStartup();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
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
      Logger("ℹ️ No existing queue entry for cleanup.");
    });

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot queueSnapshot = await transaction.get(queueRef);
      if (queueSnapshot.exists && queueSnapshot['uid'] == currentUser.uid) {
        transaction.delete(queueRef);
        Logger("🗑 Removed stale queue entry for user ${currentUser.uid}");
      }
    });

    await currentUserRef.update({
      "currentChat": null,
      "matchable": true,
    });

    Logger("🔄 Reset chat state on app start.");
  }

  Future<void> matchUsers(String user1Uid, String user2Uid,
      DocumentReference queueRef, DocumentReference user1Ref) async {
    DocumentReference user2Ref = _firestore.collection('users').doc(user2Uid);
    DocumentSnapshot user2Doc = await user2Ref.get();

    if (!user2Doc.exists ||
        user2Doc['matchable'] == false ||
        user2Doc['currentChat'] != null) {
      Logger("🚨 User $user2Uid is no longer available for matching. Removing from queue...");
      await queueRef.delete();
      return;
    }

    var newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      "participants": [user1Uid, user2Uid],
      "createdAt": FieldValue.serverTimestamp(),
      "chatStatus": "active"
    });

    Logger("✅ New chat created: ${newChatRef.id}");

    await user1Ref.update({"currentChat": newChatRef.id, "matchable": false});
    await user2Ref.update({"currentChat": newChatRef.id, "matchable": false});

    await queueRef.delete();
  }

  Future<void> startNewChatSafely() async {
    setState(() {
      _waitingForMatch = true;
    });

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      Logger("🚨 ERROR: No user is logged in.");
      return;
    }

    final String currentUid = currentUser.uid;
    final userRef = _firestore.collection('users').doc(currentUid);
    final queueRef = _firestore.collection('chat_queue').doc(currentUid);

    try {
      await queueRef.delete();
      Logger("🧹 Cleared old queue entry for $currentUid.");
    } catch (e) {
      Logger("ℹ️ No previous queue entry to delete for $currentUid.");
    }

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
          Logger("❌ ERROR: Matched document missing 'uid' field.");
          return;
        }

        final String matchedUid = matchedData['uid'];
        Logger("🎯 Match found! Matched with user $matchedUid");

        final matchedUserRef = _firestore.collection('users').doc(matchedUid);
        final matchedQueueRef =
            _firestore.collection('chat_queue').doc(matchedUid);

        final newChatRef = _firestore.collection('chats').doc();
        await newChatRef.set({
          'participants': [currentUid, matchedUid],
          'createdAt': FieldValue.serverTimestamp(),
          'chatStatus': 'active',
        });

        await userRef.update({'currentChat': newChatRef.id, 'matchable': false});
        await matchedUserRef.update({'currentChat': newChatRef.id, 'matchable': false});

        await queueRef.delete();
        await matchedQueueRef.delete();

        Logger("✅ Chat created between $currentUid and $matchedUid. Chat ID: ${newChatRef.id}");

        _listenForChatUpdates();
      } else {
        Logger("📥 No match found. Adding $currentUid to queue...");

        try {
          await queueRef.set({
            'uid': currentUid,
            'timestamp': FieldValue.serverTimestamp(),
            'category': 'General',
          });
          Logger("✅ Successfully added $currentUid to chat_queue.");
        } catch (e) {
          Logger("🚨 Failed to add user to chat_queue: $e");
        }

        Logger("✅ User $currentUid added to chat_queue.");
        _listenForChatUpdates();
      }
    } catch (e) {
      Logger("🚨 Firestore error during matchmaking: $e");
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
      if (!mounted) return;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
                'Lets Chat!',
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
          Positioned(
            left: 78,
            top: 510,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinScreen()),
                );
              },
              child: Container(
                width: 247,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Video Chat',
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
          Positioned(
            left: 120,
            top: 580,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()),
                );
              },
              child: Container(
                width: 180,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
