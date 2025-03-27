import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onLeaveButtonPressed;

  const MeetingControls(
      {super.key,
      required this.onToggleMicButtonPressed,
      required this.onToggleCameraButtonPressed,
      required this.onLeaveButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Leave Button (leftmost)
          _buildControlButton(
            icon: Icons.call_end,
            color: Color(0xFFFF8A8A), // Pastel red
            onPressed: onLeaveButtonPressed,
          ),
          
          SizedBox(width: 20),
          
          // Toggle Mic (center)
          _buildControlButton(
            icon: Icons.mic,
            color: Color(0xFF83B9FF), // Pastel blue
            onPressed: onToggleMicButtonPressed,
          ),
          
          SizedBox(width: 20),
          
          // Toggle Camera (rightmost)
          _buildControlButton(
            icon: Icons.videocam,
            color: Color(0xFFA5D6A7), // Pastel green
            onPressed: onToggleCameraButtonPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 28),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}