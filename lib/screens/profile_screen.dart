import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileField('Username', 'Jsmith11'),
            _buildProfileField('Email', 'jwsmith@calbaptist.edu'),
            _buildProfileField('Password', '**********', isObscure: true),
            _buildProfileField('First Name', 'John'),
            _buildProfileField('Last Name', 'Smith'),
            _buildProfileField('Major', 'Computer Science'),
            _buildProfileField('Tutoring Subjects', 'Computer Science, Calculus I'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5),
          TextField(
            obscureText: isObscure,
            readOnly: true,
            decoration: InputDecoration(
              hintText: value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Color(0xFFD9D9D9)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
