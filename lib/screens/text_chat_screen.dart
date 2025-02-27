import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      "message": messageText,
      "senderId": user.uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

void _leaveChat() async {
  User? user = _auth.currentUser;
  if (user == null) {
    print("No authenticated user found.");
    return;
  }

  DocumentReference userRef = _firestore.collection('users').doc(user.uid);
  DocumentSnapshot userDoc = await userRef.get();

  if (!userDoc.exists) {
    print("Current user document not found in Firestore.");
    return;
  }

  String? currentChatId = userDoc['currentChat'];
  if (currentChatId == null) {
    print("User is not currently in an active chat.");
    return;
  }

  DocumentReference chatRef = _firestore.collection('chats').doc(currentChatId);
  DocumentSnapshot chatDoc = await chatRef.get();

  if (!chatDoc.exists) {
    print("Chat document not found in Firestore.");
    return;
  }

  print("Chat found: ${chatDoc.data()}");

  List<dynamic> participants = chatDoc['participants'];
  if (participants.length < 2) {
    print("Warning: Chat has less than 2 participants.");
  }

  // Find the other user in the chat
  String? otherUserUid = participants.firstWhere((id) => id != user.uid, orElse: () => null);

  print("Current user ID: ${user.uid}");
  print("Other user UID: $otherUserUid");

  // Update current user
  await userRef.update({
    "currentChat": null,
    "matchable": true,
  });

  print("Current user ${user.uid} is now matchable again.");

  // 🔹 Instead of using Firestore document ID, search for the other user by their `uid`
  if (otherUserUid != null) {
    QuerySnapshot userQuery = await _firestore.collection('users')
        .where("uid", isEqualTo: otherUserUid)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      DocumentReference otherUserRef = userQuery.docs.first.reference;
      
      await otherUserRef.update({
        "currentChat": null,
        "matchable": true,
      });
      print("Other user ($otherUserUid) is now matchable again.");
    } else {
      print("Error: Other user document not found in Firestore.");
    }
  } else {
    print("Error: No other user found in the chat.");
  }

  print("User ${user.uid} left the chat and is matchable again.");

  // Navigate back to chat home
  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: _leaveChat, // Call leave chat function
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

  ChatBubble({required this.text, required this.isMe});

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
