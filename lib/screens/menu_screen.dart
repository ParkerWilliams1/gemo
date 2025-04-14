import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String firstName = '';
  String lastName = '';
  String email = '';
  String major = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
          email = data['email'] ?? '';
          major = data['major'] ?? '';
          username = data['username'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: $firstName', style: _textStyle()),
            const SizedBox(height: 10),
            Text('Last Name: $lastName', style: _textStyle()),
            const SizedBox(height: 10),
            Text('Username: $username', style: _textStyle()),
            const SizedBox(height: 10),
            Text('Email: $email', style: _textStyle()),
            const SizedBox(height: 10),
            Text('Major: $major', style: _textStyle()),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle() {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
  }
}
