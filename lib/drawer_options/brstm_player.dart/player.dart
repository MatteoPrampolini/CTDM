import 'dart:io';

import 'package:brstm_player/brstm.dart';
import 'package:brstm_player/brstm_player.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'loop_point_timeline.dart';

class BrstmPlayer extends StatefulWidget {
  BRSTM file;
  BrstmPlayer(this.file, {super.key});

  @override
  State<BrstmPlayer> createState() => BrstmPlayerState();
}

class BrstmPlayerState extends State<BrstmPlayer> {
  bool _isPlaying = false;
  bool _edit_loopoint_visibility = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  MPVPlayer mpv = MPVPlayer();

  @override
  void dispose() {
    mpv.quit();
    super.dispose();
  }

  void reset() {
    mpv.stop();
    audioTimelineKey.currentState?.isPlaying = false;
    audioTimelineKey.currentState?.sliderValue = 0;
    _isPlaying = false;
  }

  @override
  void initState() {
    mpv.binary = "mpv";
    mpv.pipe = r"\\.\pipe\mpvsocket_" "${widget.file.getFilePath()!}";
    if (File(mpv.pipe).existsSync()) {
      File(mpv.pipe).deleteSync();
    }
    //"${path.basename(widget.file.getFilePath()!)}";
    mpv.updateInterval = 300;
    mpv.start();
    super.initState();
  }

  void _init() async {
    await mpv.loadFile(widget.file.getFilePath()!);
  }

  Future<bool> togglePlay() async {
    _isPlaying = !_isPlaying;

    audioTimelineKey.currentState?.togglePlay();
    print(audioTimelineKey.currentState!.sliderValue);
    if (_isPlaying) {
      if (audioTimelineKey.currentState!.sliderValue == 0) {
        await mpv.loadFile(widget.file.getFilePath()!);
      } else {
        await mpv.seek(audioTimelineKey.currentState!.sliderValue);
        await mpv.play();
      }
    } else {
      await mpv.stop(); //pause() when fixed.
    }

    // if (_isPlaying) {

    //   await mpv.play();
    // } else {
    //   await mpv.pause();
    // }

    setState(() {});
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
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 80, left: 40, right: 40),
                  child: Text(path.basename(widget.file.getFilePath()!)),
                )),
            Visibility(
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              visible: _edit_loopoint_visibility,
              child: LoopPointTimeline(
                  duration: 400,
                  startLoop: 0,
                  endLoop: 1,
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
        onPressed: () async => {
          isPlaying = await widget.parentTogglePlay(),
        },
      ),
    );
  }
}
