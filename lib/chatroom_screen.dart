import 'package:flutter/material.dart';

class ChatroomScreen extends StatelessWidget {
  static const routeName = '/chatroom';
  const ChatroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Chatroom'),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 225, 127, 0),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Homepage'),
        ),
      ),
    );
  }
}