import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  final bool isMainView;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.isMainView = false,
  });

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  Stream? videoStream;

  @override
  void initState() {
    // Initial video stream for the participant
    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        }
      });
    });
    _initStreamListeners();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = stream);
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.isMainView ? 0 : 8),
        color: Colors.grey.shade800,
        boxShadow: widget.isMainView
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Soft shadow
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: videoStream != null
          ? RTCVideoView(
              videoStream?.renderer as RTCVideoRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          : Center(
              child: Icon(
                Icons.person,
                size: widget.isMainView ? 100 : 50, // Size of Small User Camera Icon
                color: Colors.white,
              ),
            ),
    );
  }
}