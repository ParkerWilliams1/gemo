import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 1,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to MenuScreen
          },
        ),
      ),
      body: Stack(
        children: [
          _toggleSetting("Tutor Profile", 149),
          _toggleSetting("Light Mode", 220),
        ],
      ),
    );
  }

  // Toggle Switch UI
  Widget _toggleSetting(String label, double top) {
    return Positioned(
      left: 40,
      top: top,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 100),
          _toggleSwitch(),
        ],
      ),
    );
  }

  // Custom Toggle Switch
  Widget _toggleSwitch() {
    return Container(
      width: 51,
      height: 31,
      padding: const EdgeInsets.only(top: 2, left: 22, right: 2, bottom: 2),
      decoration: ShapeDecoration(
        color: const Color(0xFF34C759),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0x0F000000),
                blurRadius: 1,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0x26000000),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0x0A000000),
                blurRadius: 0,
                offset: const Offset(0, 0),
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
