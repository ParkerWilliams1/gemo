import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/screens/combined_chat_screen.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  
  // VideoSDK Token
  static const String _videoChatToken = "token_goes_here";
  
  StreamSubscription<DocumentSnapshot>? _matchSubscription;
  String _currentCategory = 'General';

  // Singleton pattern
  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  // Getter for the token
  String get videoChatToken => _videoChatToken;

  // New method to create chat screen with all required parameters
  Widget createChatScreen(String roomId) {
    return CombinedChatScreen(
      chatId: roomId,
      meetingId: roomId,
      token: _videoChatToken,
      category: _currentCategory,
    );
  }

  Future<void> startMatch({
    required String category,
    required BuildContext context,
    required VoidCallback onMatchStarted,
    required Function(String) onMatchFound,
    required Function(String) onError,
  }) async {
    _currentCategory = category;
    onMatchStarted();

    try {
      // Update category clicks if needed
      final snap = await _firestore
          .collection('categories')
          .where('displayName', isEqualTo: category)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await _firestore.collection('categories').doc(snap.docs.first.id).update({
          "clicks": FieldValue.increment(1)
        });
      }

      // Start the match
      final result = await _functions.httpsCallable('matchUser').call({
        'category': category
      });

      if (result.data['isNewMatch'] == true) {
        onMatchFound(result.data['roomId']);
      } else {
        _listenForMatch(onMatchFound, onError);
      }
    } catch (e) {
      onError('Failed to start match: ${e.toString()}');
    }
  }

  void _listenForMatch(
    Function(String) onMatchFound,
    Function(String) onError,
  ) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      onError('User not authenticated');
      return;
    }

    _matchSubscription?.cancel(); // Cancel any existing subscription
    _matchSubscription = _firestore.collection('rooms').doc(uid).snapshots().listen(
      (doc) {
        if (doc.exists && doc.data()?['status'] == 'matched') {
          onMatchFound(doc.data()?['roomId']);
        }
      },
      onError: (error) => onError(error.toString()),
    );
  }

  Future<Map<String, dynamic>> findMatch(String category) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final result = await _functions
          .httpsCallable('matchUser')
          .call({'cat': category});

      return result.data;
    } catch (e) {
      throw Exception('Match failed: ${e.toString()}');
    }
  }

  void dispose() {
    _matchSubscription?.cancel();
  }

  Future<void> cancelMatch() async {
    await _cleanupWaitingRoom();
    _matchSubscription?.cancel();
  }

  Future<void> _cleanupWaitingRoom() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('rooms').doc(uid).delete();
    }
  }
}