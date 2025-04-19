import 'package:flutter/material.dart';

class MeetingControls extends StatelessWidget {
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onLeaveButtonPressed;
  final void Function() onToggleChatButtonPressed;
  final bool isChatOpen;

  const MeetingControls({
    super.key,
    required this.onToggleMicButtonPressed,
    required this.onToggleCameraButtonPressed,
    required this.onLeaveButtonPressed,
    required this.onToggleChatButtonPressed,
    required this.isChatOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Toggle Chat Button
          _buildControlButton(
            icon: isChatOpen ? Icons.close : Icons.chat,
            color: Color(0xFFFFD59E), // Pastel orange
            onPressed: onToggleChatButtonPressed,
          ),
          
          SizedBox(width: 20),
          
          // Toggle Mic Button
          _buildControlButton(
            icon: Icons.mic,
            color: Color(0xFF83B9FF), // Pastel blue
            onPressed: onToggleMicButtonPressed,
          ),
          
          SizedBox(width: 20),
          
          // Toggle Camera Button
          _buildControlButton(
            icon: Icons.videocam,
            color: Color(0xFFA5D6A7), // Pastel green
            onPressed: onToggleCameraButtonPressed,
          ),
          
          SizedBox(width: 20),
          
          // Leave Button
          _buildControlButton(
            icon: Icons.call_end,
            color: Color(0xFFFF8A8A), // Pastel red
            onPressed: onLeaveButtonPressed,
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 26),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}