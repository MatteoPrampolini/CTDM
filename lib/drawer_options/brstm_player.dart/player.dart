import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';

import 'loop_point_timeline.dart';

class BrstmPlayer extends StatefulWidget {
  const BrstmPlayer({super.key});

  @override
  State<BrstmPlayer> createState() => _BrstmPlayerState();
}

class _BrstmPlayerState extends State<BrstmPlayer> {
  bool _isPlaying = false;
  bool _edit_loopoint_visibility = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  bool togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    //call AudioTimeline.start()
    audioTimelineKey.currentState?.togglePlay();
    return _isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 40),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.amberAccent)), // Change the color here,
                onPressed: () => {
                      setState(() {
                        _edit_loopoint_visibility = !_edit_loopoint_visibility;
                      })
                    },
                child: const Text(
                  "Edit Loop Points",
                  style: TextStyle(color: Colors.black87),
                )),
          ),
        ),
        Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 80, left: 40, right: 40),
                  child: Text("filename"),
                )),
            Visibility(
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              visible: _edit_loopoint_visibility,
              child: LoopPointTimeline(
                  duration: 400,
                  startLoop: 100,
                  endLoop: 300,
                  onLoopPointChange: (double) => {print("changed")}),
            ),
            AudioTimeline(
                key: audioTimelineKey,
                currentPosition: 0,
                duration: 400,
                loopPoint: 100,
                onSeek: (value) {
                  audioTimelineKey.currentState?.sliderValue = value;
                },
                onLoopPointChange: (value) {}),
            PlayButton(togglePlay),
          ],
        ),
      ],
    );
  }
}

class PlayButton extends StatefulWidget {
  final Function parentTogglePlay;
  const PlayButton(this.parentTogglePlay, {super.key});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.red,
      child: IconButton(
        color: Colors.white,
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () => {
          isPlaying = widget.parentTogglePlay(),
        },
      ),
    );
  }
}
