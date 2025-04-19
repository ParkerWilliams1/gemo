import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemo/video_stream/meeting_screen.dart';

class CombinedChatScreen extends StatefulWidget {
  final String chatId;
  final String meetingId;
  final String token;
  final String category;

  const CombinedChatScreen({
    Key? key,
    required this.chatId,
    required this.meetingId,
    required this.token,
    required this.category,
  }) : super(key: key);

  @override
  _CombinedChatScreenState createState() => _CombinedChatScreenState();
}

class _CombinedChatScreenState extends State<CombinedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  bool _showChat = true;
  bool _showInput = false;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _startFadeTimer();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showChat = false;
          _showInput = false;
        });
      }
    });
  }

  void _resetFadeTimer() {
    _startFadeTimer();
    if (!_showChat) {
      setState(() {
        _showChat = true;
      });
    }
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
      print("Error sending message: $e");
    }

    _messageController.clear();
    _resetFadeTimer();
  }

  void _toggleChat() {
    setState(() {
      _showInput = !_showInput;
      _showChat = true;
    });
    _resetFadeTimer();
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
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message display area
                      Container(
                        constraints: BoxConstraints(maxHeight: 150),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
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
                                bool isMe = senderId == _auth.currentUser!.uid;
                                String displayName = isMe ? "You" : senderId;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        displayName,
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
                        ),
                      ),

                      // Input bar
                      if (_showInput)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
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
                                  onTap: _resetFadeTimer,
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