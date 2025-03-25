import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:gemo/screens/waiting_for_match_screen.dart';
import 'package:logger/logger.dart';

class MatchmakingService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _queue = [];
  final List<Map<String, String>> _matches = [];
  final Logger _logger = Logger(); // Initialize Logger

  List<Map<String, String>> get matches => _matches;

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

  
 void endCall(String userId1, String userId2) {
    _logger.i("Ending call between $userId1 and $userId2.");

    // Remove the match if it exists
    final matchIndex = _matches.indexWhere((match) =>
        (match['user1'] == userId1 && match['user2'] == userId2) ||
        (match['user1'] == userId2 && match['user2'] == userId1));

    if (matchIndex != -1) {
      _matches.removeAt(matchIndex);
      _logger.d("Match between $userId1 and $userId2 removed. Current matches: $_matches");
    } else {
      _logger.w("No match found between $userId1 and $userId2.");
    }

    // Add users back to the queue
    _queue.add(userId1);
    _queue.add(userId2);
    _logger.d("Users $userId1 and $userId2 added back to the queue. Current queue: $_queue");

    _tryMatch();
  }

  void _tryMatch() {
    _logger.i("Attempting to match users...");
    while (_queue.length >= 2) {
      final user1 = _queue.removeAt(0);
      final user2 = _queue.removeAt(0);
      _matches.add({'user1': user1, 'user2': user2});
      _logger.d("Matched $user1 with $user2. Current matches: $_matches");
      notifyListeners();
    }
    if (_queue.length < 2) {
      _logger.d("Not enough users in the queue to create a match. Current queue: $_queue");
    }
  }
}

