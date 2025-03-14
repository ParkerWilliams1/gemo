import 'package:flutter/material.dart';
import 'package:gemo/services/user_matching.dart';
import 'package:gemo/screens/text_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  ChatSearchScreenState createState() => ChatSearchScreenState();
}

class ChatSearchScreenState extends State<ChatSearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MatchmakingService _matchmakingService = MatchmakingService();

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    _matchmakingService.joinQueue(user.uid);

    _matchmakingService.addListener(() {
      final matches = _matchmakingService.matches;
      final match = matches.firstWhere(
        (match) => match['user1'] == user.uid || match['user2'] == user.uid,
        orElse: () => <String, String>{},
      );

      if (match.isNotEmpty) {
        String chatId = match['user1'] == user.uid ? match['user2']! : match['user1']!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatId: chatId),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching for a match...'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}