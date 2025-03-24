import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/screens/text_chat_screen.dart';

class WaitingForMatchScreen extends StatefulWidget {
  final String category;
  final VoidCallback onCancel;

  const WaitingForMatchScreen({
    super.key,
    required this.category,
    required this.onCancel,
  });

  @override
  State<WaitingForMatchScreen> createState() => _WaitingForMatchScreenState();
}

class _WaitingForMatchScreenState extends State<WaitingForMatchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _listenForChatAssignment();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _listenForChatAssignment() {
    final user = _auth.currentUser;
    if (user == null) return;

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!mounted) return;
      final data = doc.data();
      final chatId = data?['currentChat'];

      if (chatId != null && chatId.toString().isNotEmpty) {
        _userSubscription?.cancel(); // Stop listening once matched
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
        );
      }
    });
  }

  Future<void> _handleCancel() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final queueRef = _firestore.collection('chat_queue').doc(uid);

    try {
      await queueRef.delete();
      await _firestore.collection('users').doc(uid).update({
        'currentChat': null,
        'matchable': true,
      });
      print("🔙 User $uid canceled matchmaking and removed from queue.");
    } catch (e) {
      print("⚠️ Error removing user from queue: $e");
    }

    _userSubscription?.cancel();
    widget.onCancel(); // Triggers the callback to return to CategoriesScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Looking for a match in '${widget.category}'...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
