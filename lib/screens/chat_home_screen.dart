import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemo/screens/menu_screen.dart';
import 'package:gemo/screens/categories_screen.dart';
import 'package:gemo/services/match_service.dart';

class ChatHomeScreen extends StatefulWidget {
  static const String routeName = '/chathome';

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  bool _isMatching = false;
  final MatchService _matchService = MatchService();

  @override
  void dispose() {
    _matchService.dispose();
    super.dispose();
  }

  Future<void> _startVideoMatch(String category) async {
    _matchService.startMatch(
      category: category,
      context: context,
      onMatchStarted: () => setState(() => _isMatching = true),
      onMatchFound: (roomId) => _joinVideoRoom(roomId),
      onError: (error) {
        setState(() => _isMatching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  void _joinVideoRoom(String roomId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MatchService().createChatScreen(roomId),
    ),
  ).then((_) => setState(() => _isMatching = false));
}

  Future<void> _cancelMatch() async {
    await _matchService.cancelMatch();
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
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
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
    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
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
      MaterialPageRoute(builder: (context) => CategoriesScreen()),
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
          )
        ],
      ),
    );
  }
}