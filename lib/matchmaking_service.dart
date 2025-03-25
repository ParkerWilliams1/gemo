import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:logger/logger.dart';

class MatchmakingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startCategoryChat(BuildContext context, String category) async {
    final user = _auth.currentUser;
    if (user == null) {
      Logger().e("No authenticated user found.");
      return;
    }

    final uid = user.uid;
    final queueRef = _firestore.collection('chat_queue').doc(uid);
    final userRef = _firestore.collection('users').doc(uid);

    // 🧹 Clear stale queue entry for this user
    await queueRef.delete().catchError((_) {
      Logger().w("Failed to delete stale queue entry for user $uid.");
    });

    // 🔍 Try to match with another user in the same category
    final snapshot = await _firestore
        .collection('chat_queue')
        .where('uid', isNotEqualTo: uid)
        .where('category', isEqualTo: category) // ✅ Use the selected category
        .orderBy('timestamp')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final matchedDoc = snapshot.docs.first;
      final matchedUid = matchedDoc['uid'];
      final matchedRef = _firestore.collection('users').doc(matchedUid);

      final newChatRef = _firestore.collection('chats').doc();
      await newChatRef.set({
        'participants': [uid, matchedUid],
        'createdAt': FieldValue.serverTimestamp(),
        'chatStatus': 'active',
        'category': category,
      });

      await userRef.update({'currentChat': newChatRef.id, 'matchable': false});
      await matchedRef
          .update({'currentChat': newChatRef.id, 'matchable': false});

      await queueRef.delete();
      await _firestore.collection('chat_queue').doc(matchedUid).delete();

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TextChatScreen(
              chatId: newChatRef.id, // Pass the required chatId
            ),
          ),
        );
      }
    } else {
      // No match found, navigate to WaitingForMatchScreen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WaitingForMatchScreen(
            ),
          ),
        );
      }
    }
  }

  void joinQueue(String uid, String category) {
    _firestore.collection('chat_queue').doc(uid).set({
      'uid': uid,
      'category': category, // ✅ Store the selected category
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void leaveQueue(String uid) {
    _firestore.collection('chat_queue').doc(uid).delete();
  }
}
