import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemo/models/user_profile.dart';
import 'package:gemo/constants/majors.dart'; // Make sure this file contains `majorsList`

class ProfileSetupScreen extends StatefulWidget {
  final String uid;

  const ProfileSetupScreen({required this.uid, super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedMajor;
  bool _isTutor = false;
  bool _loading = false;

  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email ?? '';
      final domain = email.contains('@') ? email.split('@').last : '';

      final profile = UserProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        email: email,
        schoolDomain: domain,
        createdAt: DateTime.now(),
        major: _selectedMajor,
        isTutor: _isTutor,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap());

      setState(() => _loading = false);

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Up Profile")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter your age" : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedMajor,
                      decoration: const InputDecoration(labelText: "Major"),
                      items: majorsList
                          .map((major) => DropdownMenuItem(
                                value: major,
                                child: Text(major),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedMajor = val),
                      validator: (val) =>
                          val == null ? "Please select a major" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Enable Tutoring Profile",
                            style: TextStyle(fontSize: 16)),
                        Switch(
                          value: _isTutor,
                          onChanged: (val) =>
                              setState(() => _isTutor = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitProfile,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
