import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'meeting_controls.dart';
import './participant_tile.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;

  const MeetingScreen({
    super.key,
    required this.meetingId,
    required this.token,
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
      }
    });

    _room.on(Events.roomLeft, () {
      if (mounted) {
        participants.clear();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (Route<dynamic> route) => false,
        );
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
    // Get the local participant
    final localParticipant = _room.localParticipant;
    
    // Get the first remote participant (if available)
    final remoteParticipants = participants.values.where((p) => p.id != localParticipant.id).toList();
    final Participant? remoteParticipant = remoteParticipants.isNotEmpty ? remoteParticipants.first : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              // Show remote participant in fullscreen if available
              if (remoteParticipant != null)
                Positioned.fill(
                  child: ParticipantTile(
                    key: Key(remoteParticipant.id),
                    participant: remoteParticipant,
                    isMainView: true,
                  ),
                ),

              // Local user’s camera preview in the top-right corner
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

              // Meeting controls at the bottom
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}