import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';

class MatchmakingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startCategoryChat(BuildContext context, String category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final queueRef = _firestore.collection('chat_queue').doc(uid);
    final userRef = _firestore.collection('users').doc(uid);

    // Clear stale queue entry
    await queueRef.delete().catchError((_) {});

    // Try to match with another user in the same category
    final snapshot = await _firestore
        .collection('chat_queue')
        .where('uid', isNotEqualTo: uid)
        .where('category', isEqualTo: category)
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatId: newChatRef.id)),
      );
    } else {
      await queueRef.set({
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'category': category,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingForMatchScreen(
            category: category,
            onCancel: () {
              Navigator.pop(context); // just return to the previous screen
            },
          ),
        ),
      );
    }
  }
}
