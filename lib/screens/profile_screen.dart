/*
    profile_screen.dart
    February 18, 2025
    Grace Bergquist
    This file contains the logic for the profile screen, where users can view and edit their profile information.
    
    Functions:
    - ProfileScreen: Constructor for the ProfileScreen class
    - _ProfileScreenState: State class for the ProfileScreen
    - initState: Initializes the state of the ProfileScreen
    - _saveAndReturn: Saves the profile information and returns to the previous screen
    - build: Builds the profile screen with the specified layout and design
    - _buildProfileField: Builds a profile field with a label and text field

    Variables Accessed by Module:
    - firstName: The user's first name
    - lastName: The user's last name
    - major: The user's major
    - subjects: The subjects the user tutors
    - username: The user's username
    - email: The user's email
    - password: The user's password

    History of Modifications:
    - N/A
*/

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';  
  final String firstName;
  final String lastName;
  final String major;
  final String subjects;
  final String username;
  final String email;
  final String password;

  const ProfileScreen({super.key, 
    this.firstName = '',
    this.lastName = '',
    this.major = '',
    this.subjects = '',
    this.username = '',
    this.email = '',
    this.password = '',
  });

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController majorController;
  late TextEditingController subjectsController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  
  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    majorController = TextEditingController(text: widget.major);
    subjectsController = TextEditingController(text: widget.subjects);
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  void _saveAndReturn() {
    Navigator.pop(context, {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'major': majorController.text,
      'subjects': subjectsController.text,
      'username': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileField('First Name', firstNameController),
            _buildProfileField('Last Name', lastNameController),
            _buildProfileField('Major', majorController),
            _buildProfileField('Tutoring Subjects', subjectsController),
            _buildProfileField('Username', usernameController),
            _buildProfileField('Email', emailController),
            _buildProfileField('Password', passwordController, isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndReturn,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
