import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'meeting_controls.dart';
import './participant_tile.dart';

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String token;

  const MeetingScreen(
      {super.key, required this.meetingId, required this.token});

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
    // create room
    _room = VideoSDK.createRoom(
      roomId: widget.meetingId,
      token: widget.token,
      // TODO: Put in place a function that will pull displayName from their Firebase
      displayName: "John Doe",
      micEnabled: micEnabled,
      camEnabled: camEnabled,
      // multiStream is disabled to fix camera issue
      multiStream: false,
      // Set default camera to 0 when on laptop/pc (webcam) & 1 when on mobile (front-facing)
      defaultCameraIndex: kIsWeb ? 0 : 1 
    );

    setMeetingEventListener();

    // Join room
    _room.join();

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // listening to meeting events
  void setMeetingEventListener() {
    _room.on(Events.roomJoined, () {
      setState(() {
        participants.putIfAbsent(
            _room.localParticipant.id, () => _room.localParticipant);
      });
    });

    _room.on(
      Events.participantJoined,
      (Participant participant) {
        setState(
          () => participants.putIfAbsent(participant.id, () => participant),
        );
      },
    );

    _room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(
          () => participants.remove(participantId),
        );
      }
    });

    _room.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  // onbackButton pressed leave the room
  Future<bool> _onWillPop() async {
    _room.leave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              // Main view for the remote user
              if (participants.isNotEmpty)
                Positioned.fill(
                  child: ParticipantTile(
                    key: Key(participants.values.first.id),
                    participant: participants.values.first,
                    isMainView: true,
                  ),
                ),

              // Local user's camera in a smaller box at the top-right corner
              if (participants.length > 1)
                Positioned(
                  top: 16,
                  right: 16,
                  child: SizedBox(
                    width: 120,
                    height: 160,
                    child: ParticipantTile(
                      key: Key(participants.values.elementAt(1).id),
                      participant: participants.values.elementAt(1),
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
                    micEnabled ? _room.muteMic() : _room.unmuteMic();
                    micEnabled = !micEnabled;
                  },
                  onToggleCameraButtonPressed: () {
                    camEnabled ? _room.disableCam() : _room.enableCam();
                    camEnabled = !camEnabled;
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