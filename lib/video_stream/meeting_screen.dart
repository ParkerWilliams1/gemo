import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'meeting_controls.dart';
import './participant_tile.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;
  final String category;
  final void Function() onToggleChat;
  final bool isChatOpen;

  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.token,
    required this.category,
    required this.onToggleChat,
    required this.isChatOpen,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  late Room _room;
  var micEnabled = true;
  var camEnabled = true;

  Map<String, Participant> participants = {};

  @override
  void initState() {
    super.initState();

    // Create room
    _room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      displayName: "John Doe",
      micEnabled: micEnabled,
      camEnabled: camEnabled,
      multiStream: false, // Ensure single stream mode
      defaultCameraIndex: kIsWeb ? 0 : 1,
    );

    setMeetingEventListener();
    _room.join();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void setMeetingEventListener() {
  _room.on(Events.roomJoined, () {
    setState(() {
      participants[_room.localParticipant.id] = _room.localParticipant;
    });
  });

  _room.on(Events.participantJoined, (Participant participant) {
    setState(() {
      participants[participant.id] = participant;
    });
  });

  _room.on(Events.participantLeft, (String participantId) {
  if (participants.containsKey(participantId)) {
    setState(() {
      participants.remove(participantId);
    });
    
    if (mounted) {
      participants.clear();
      _room.leave(); // Will trigger roomLeft
      // Don't navigate here - let roomLeft handle it
    }
  }
});

  _room.on(Events.roomLeft, () {
  if (mounted) {
    participants.clear();
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context); // Return to previous screen
    } else {
      // Fallback if no previous screen exists
      Navigator.pushReplacementNamed(context, '/home'); 
    }
  }
});
}

  // Handle leaving the room when back button is pressed
  Future<bool> _onWillPop() async {
    _room.leave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localParticipant = _room.localParticipant;
    final remoteParticipants = participants.values.where((p) => p.id != localParticipant.id).toList();
    final Participant? remoteParticipant = remoteParticipants.isNotEmpty ? remoteParticipants.first : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              // Remote participant view
              if (remoteParticipant != null)
                Positioned.fill(
                  child: ParticipantTile(
                    key: Key(remoteParticipant.id),
                    participant: remoteParticipant,
                    isMainView: true,
                  ),
                ),

              // Local participant preview
              Positioned(
                top: 16,
                right: 16,
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: ParticipantTile(
                    key: Key(localParticipant.id),
                    participant: localParticipant,
                    isMainView: false,
                  ),
                ),
              ),

              // Category label
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Meeting controls
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: MeetingControls(
                  onToggleMicButtonPressed: () {
                    setState(() {
                      micEnabled ? _room.muteMic() : _room.unmuteMic();
                      micEnabled = !micEnabled;
                    });
                  },
                  onToggleCameraButtonPressed: () {
                    setState(() {
                      camEnabled ? _room.disableCam() : _room.enableCam();
                      camEnabled = !camEnabled;
                    });
                  },
                  onLeaveButtonPressed: () {
                    _room.leave();
                  },
                  onToggleChatButtonPressed: widget.onToggleChat,
                  isChatOpen: widget.isChatOpen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final categoryColors = {
      'Music': Color(0xFF0080FF),
      'Gaming': Color(0xFF008000),
      'Movies': Color(0xFFff5733),
      'Sports': Color(0xFFFFA500),
      'Travel': Color(0xFFAC33FF),
      'Fitness': Color(0xFFFFFF00),
      'Fashion': Color(0xFFFE7AE2),
      'Food': Color(0xFFFFC0CB),
      'Photography': Color(0xFF00FFFF),
      'Health': Color(0xFFFE5EE6),
      'Business': Color(0xFF00FF00),
      'Finance': Color(0xFFFFBF00),
      'Electrical Engineering': Color(0xFFFF5454),
      'Calculus': Color(0xFFFFBF00),
      'Physics': Color(0xFF008080),
      'Chemistry': Color(0xFFFFC0CB),
      'Economics': Color(0xFF00FFFF),
      'Psychology': Color(0xFFA254FF),
      'History': Color(0xFFE7BB92),
      'Computer Science': Color(0xFF0080FF),
      'Mechanical Engineering': Color(0xFF008000),
      'Civil Engineering': Color(0xFFFFA500),
      'Chemical Engineering': Color(0xFF00FF00),
      'Bio Engineering': Color(0xFFFFFF00),
      'General': Color.fromARGB(255, 132, 132, 132),
    };
    
    return categoryColors[categoryName] ?? Color.fromARGB(255, 132, 132, 132);
  }
}