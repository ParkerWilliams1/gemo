import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: -36,
            top: -33,
            child: Container(
              width: 473,
              height: 136,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFD9D9D9), width: 1),
              ),
            ),
          ),
          Positioned(
            left: 167,
            top: 61,
            child: Text(
              'Chat',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 273,
            top: 38,
            child: Container(
              width: 113,
              height: 52,
              decoration: BoxDecoration(
                color: Color(0xFF83B9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'New Chat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 48,
            child: Container(
              width: 48,
              height: 48,
              child: FlutterLogo(),
            ),
          ),
          Positioned(
            left: 304,
            top: 162,
            child: ChatBubble(text: 'Hello!', alignment: Alignment.centerRight),
          ),
          Positioned(
            left: 22,
            top: 226,
            child: ChatBubble(text: 'Hi!', alignment: Alignment.centerLeft),
          ),
          Positioned(
            left: 172,
            top: 296,
            child: ChatBubble(text: 'How is your day today?', alignment: Alignment.centerRight),
          ),
          Positioned(
            left: 22,
            top: 772,
            child: Container(
              width: 309,
              height: 47,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  'Chat here!',
                  style: TextStyle(
                    color: Color(0xFF868686),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 341,
            top: 772,
            child: Container(
              width: 42,
              height: 47,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Icon(Icons.send)),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final Alignment alignment;

  ChatBubble({required this.text, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFD9D9D9),
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
