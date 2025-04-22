import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/video_stream/meeting_screen.dart';
import 'package:logging/logging.dart';

class CombinedChatScreen extends StatefulWidget {
  final String chatId;
  final String meetingId;
  final String token;
  final String category;

  const CombinedChatScreen({
    super.key,
    required this.chatId,
    required this.meetingId,
    required this.token,
    required this.category,
  });

  @override
  CombinedChatScreenState createState() => CombinedChatScreenState();
}

class CombinedChatScreenState extends State<CombinedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  bool _showChat = false;
  bool _showInput = false;

  // Helper function to get user email by UID
  Future<String> _getUserEmail(String uid) async {
    if (uid == _auth.currentUser?.uid) {
      return "You";
    }
    
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('email') ?? uid; // Return email or fallback to UID
      }
      return uid; // Fallback to UID if user not found
    } catch (e) {
      Logger("Error fetching user email: $e");
      return uid; // Fallback to UID on error
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        "message": messageText,
        "senderId": user.uid,
        "timestamp": FieldValue.serverTimestamp(),
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      Logger("Error sending message: $e");
    }

    _messageController.clear();
  }

  void _toggleChat() {
    setState(() {
      _showInput = !_showInput;
      if (_showChat) {
        _showChat = false;
      } else {
        _showChat = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Meeting Screen (full background)
          MeetingScreen(
            meetingId: widget.meetingId,
            token: widget.token,
            category: widget.category,
            onToggleChat: _toggleChat,
            isChatOpen: _showInput,
          ),

          // Chat overlay
          if (_showChat)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 120), // Space for controls
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message display area
                      Container(
                        constraints: BoxConstraints(maxHeight: 150),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(25),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .doc(widget.chatId)
                              .collection('messages')
                              .orderBy('timestamp', descending: false)
                              .limitToLast(3)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return SizedBox();

                            var messages = snapshot.data!.docs.toList();

                            return ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                var message = messages[index];
                                String messageText = message['message'];
                                String senderId = message['senderId'];
                                
                                return FutureBuilder<String>(
                                  future: _getUserEmail(senderId),
                                  builder: (context, emailSnapshot) {
                                    String displayName = emailSnapshot.data ?? senderId;
                                    bool isMe = senderId == _auth.currentUser!.uid;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            isMe ? "You" : displayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            messageText,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Input bar
                      if (_showInput)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(25),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                  decoration: InputDecoration(
                                    hintText: "Type a message...",
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send, color: Colors.white),
                                onPressed: _sendMessage,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}