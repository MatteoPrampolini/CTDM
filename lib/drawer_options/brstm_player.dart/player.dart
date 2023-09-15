import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';

class BrstmPlayer extends StatefulWidget {
  const BrstmPlayer({super.key});

  @override
  State<BrstmPlayer> createState() => _BrstmPlayerState();
}

class _BrstmPlayerState extends State<BrstmPlayer> {
  bool _isPlaying = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  bool togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    //call AudioTimeline.start()
    audioTimelineKey.currentState!.togglePlay();
    return _isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AudioTimeline(
            key: audioTimelineKey,
            currentPosition: 0,
            duration: 400,
            loopPoint: 100,
            onSeek: (value) {
              audioTimelineKey.currentState?.sliderValue = value;
            },
            onLoopPointChange: (value) {}),
        PlayButton(togglePlay)
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
