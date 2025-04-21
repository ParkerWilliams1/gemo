import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/screens/categories_screen.dart';
import 'package:gemo/screens/combined_chat_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  static const String routeName = '/chathome';
  const ChatHomeScreen({super.key});

  @override
  ChatHomeScreenState createState() => ChatHomeScreenState();
}

class ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');
  bool _isMatching = false;
  StreamSubscription<DocumentSnapshot>? _matchSubscription;
  String _currentCategory = 'General';

  @override
  void dispose() {
    _matchSubscription?.cancel();
    _cleanupWaitingRoom();
    super.dispose();
  }

  Future<void> _cleanupWaitingRoom() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('rooms').doc(uid).delete();
    }
  }

  Future<void> _startVideoMatch(String category) async {
    setState(() {
      _isMatching = true;
      _currentCategory = category; // Set the current category
    });

    try {
      final result = await _functions
          .httpsCallable('matchUser')
          .call({'category': category});

      if (result.data['isNewMatch'] == true) {
        _joinVideoRoom(result.data['roomId']);
      } else {
        _listenForMatch();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMatching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start video chat: ${e.toString()}')),
      );
    }
  }

  void _listenForMatch() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _matchSubscription =
        _firestore.collection('rooms').doc(uid).snapshots().listen((doc) {
      if (doc.exists && doc.data()?['status'] == 'matched') {
        _joinVideoRoom(doc.data()?['roomId']);
      }
    });
  }

  void _joinVideoRoom(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CombinedChatScreen(
          chatId: roomId, // or generate a separate chat ID if needed
          meetingId: roomId,
          token: "my_token_here",
          category: _currentCategory,
        ),
      ),
    ).then((_) => setState(() => _isMatching = false));
  }

  Future<void> _cancelMatch() async {
    await _cleanupWaitingRoom();
    _matchSubscription?.cancel();
    setState(() => _isMatching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/HomeScreen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isMatching)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Finding your match...', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cancelMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lets Chat!',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 62,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () => _startVideoMatch('General'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF83B9FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'New Chat',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200, // adjust this to control the width
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoriesScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3D3D3), // Light grey
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}
