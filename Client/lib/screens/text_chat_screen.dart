import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_home_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _participantName = "Chat"; // Default title

  @override
  void initState() {
    super.initState();
    _fetchParticipantName();
  }

  // Fetch the name of the other participant
  void _fetchParticipantName() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot chatDoc =
        await _firestore.collection('chats').doc(widget.chatId).get();

    if (!chatDoc.exists) return;

    List<dynamic> participants = chatDoc['participants'];
    String? otherUserUid =
        participants.firstWhere((id) => id != user.uid, orElse: () => null);

    if (otherUserUid != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(otherUserUid).get();

      if (userDoc.exists && userDoc['email'] != null && mounted) {
        setState(() {
          _participantName = userDoc['email'];
        });
      }
    }
  }

  // Send a message
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

      print("Message sent: $messageText");
    } catch (e) {
      print("Error sending message: $e");
    }

    _messageController.clear();
  }

  // Leave the chat
  void _leaveChat() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("🚨 No authenticated user found.");
      return;
    }

    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    DocumentSnapshot userDoc = await userRef.get();

    if (!userDoc.exists) {
      print("🚨 Current user document not found in Firestore.");
      return;
    }

    DocumentReference chatRef =
        _firestore.collection('chats').doc(widget.chatId);
    DocumentSnapshot chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      print("🚨 Chat document not found in Firestore.");
      return;
    }

    List<dynamic> participants = chatDoc['participants'];
    String? otherUserUid =
        participants.firstWhere((id) => id != user.uid, orElse: () => null);

    // 🔹 Step 1: Reset the current user's chat status
    await userRef.update({
      "currentChat": null,
      "matchable": true,
    });

    print("✅ Current user ${user.uid} is now matchable again.");

    // 🔹 Step 2: If there's another participant, reset their status too
    if (otherUserUid != null) {
      DocumentReference otherUserRef =
          _firestore.collection('users').doc(otherUserUid);
      await otherUserRef.update({
        "currentChat": null,
        "matchable": true,
      });
      print("✅ Other user ($otherUserUid) is now matchable again.");
    }

    // 🔹 Step 3: Remove user from chat participants
    await chatRef.update({
      "participants": FieldValue.arrayRemove([user.uid]),
    });

    print("✅ User ${user.uid} left the chat.");

    // 🔹 Step 4: Navigate back to ChatHomeScreen instead of popping
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_participantName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: _leaveChat,
          )
        ],
      ),
      body: Column(
        children: [
          // **Message List (Real-time Updates)**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    String messageText = message['message'];
                    String senderId = message['senderId'];
                    bool isMe = senderId == _auth.currentUser!.uid;

                    return ChatBubble(
                      text: messageText,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // **Message Input Field**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Color(0xFFD9D9D9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 47,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Icon(Icons.send, color: Colors.black)),
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

// **ChatBubble Widget**
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF83B9FF) : Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
