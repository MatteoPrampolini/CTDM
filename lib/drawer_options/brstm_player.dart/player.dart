import 'dart:io';

import 'package:brstm_player/brstm.dart';
import 'package:brstm_player/brstm_player.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'loop_point_timeline.dart';

// ignore: must_be_immutable
class BrstmPlayer extends StatefulWidget {
  BRSTM file;
  BrstmPlayer(this.file, {super.key});

  @override
  State<BrstmPlayer> createState() => BrstmPlayerState();
}

class BrstmPlayerState extends State<BrstmPlayer> {
  late BRSTM file;

  int _loopStart = 0;
  int _loopEnd = 0;
  int _totalSamples = 0;
  int _sampleRate = 0;
  bool _isPlaying = false;
  bool _editLoopointVisibility = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  GlobalKey<PlayButtonState> playButtonKey = GlobalKey();

  MPVPlayer mpv = MPVPlayer();

  @override
  void dispose() {
    mpv.quit();

    super.dispose();
  }

  reset(BRSTM brstm) async {
    await mpv.quit();

    playButtonKey.currentState?.isPlaying = false;
    audioTimelineKey.currentState?.isPlaying = false;
    playButtonKey.currentState?.setState(() {});
    audioTimelineKey.currentState?.sliderValue = 0;
    _isPlaying = false;
    file.close();

    file = brstm;
    audioTimelineKey.currentState?.setState(() {
      audioTimelineKey.currentState?.filechanged(brstm);
    });
  }

  @override
  void initState() {
    file = widget.file;

    mpv.binary = "mpv";
    mpv.pipe =
        (Platform.isWindows ? r"\\.\pipe\mpvsocket_" : "/tmp/mpvsocket_") +
            path.basenameWithoutExtension(file.getFilePath()!);

    if (File(mpv.pipe).existsSync()) {
      File(mpv.pipe).deleteSync();
    }
    //"${path.basename(widget.file.getFilePath()!)}";

    reloadFile();
    super.initState();
    setState(() {});
  }

  reloadFile() {
    file.open();
    file.readSync();
    mpv.updateInterval = 300;

    file.open();
    file.readSync();
    _loopStart = file.getLoopStart()!;
    _loopEnd = file.getLoopEnd()!;
    _totalSamples = file.getTotalSamples()!;
    _sampleRate = file.getSampleRate()!;
    audioTimelineKey.currentState?.filechanged(file);

    setState(() {});
  }

  Future<bool> togglePlay({bool? value}) async {
    _isPlaying = value ?? !_isPlaying;
    playButtonKey.currentState?.isPlaying = _isPlaying;

    if (!mpv.getRunningState()) {
      await mpv.start(hangIndefinitely: true);

      // await mpv.loadFile(file.getFilePath()!);
      // _isFileLoaded = true;
      // if (audioTimelineKey.currentState!.sliderValue > 0) {
      //   await mpv.pause();
      //   await Future.delayed(const Duration(seconds: 1));
      //   await mpv.seek(audioTimelineKey.currentState!.sliderValue);
      //   //await mpv.play();
      // }
    }

    if (_isPlaying) {
      //if it should play
      if (!mpv.isPlaying) {
        await Future.delayed(const Duration(milliseconds: 300));
        await mpv.loadFile(file.getFilePath()!);
      }
      if (audioTimelineKey.currentState!.sliderValue > 0) {
        await mpv.pause();
        //await Future.delayed(const Duration(milliseconds: 300));
        await mpv.seek(audioTimelineKey.currentState!.sliderValue);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      //await mpv.play();
      //await Future.delayed(const Duration(milliseconds: 300));
      await mpv.play();
    } else {
      await mpv.pause();
    }

    // if (_isPlaying) {

    //   await mpv.play();
    // } else {
    //   await mpv.pause();
    // }
    audioTimelineKey.currentState?.togglePlay();
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
                        _editLoopointVisibility = !_editLoopointVisibility;
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
              visible: _editLoopointVisibility,
              child: LoopPointTimeline(
                  totalSamples: _totalSamples,
                  startLoop: _loopStart,
                  endLoop: _loopEnd,
                  sampleRate: _sampleRate,
                  onLoopPointChange: (n) => {print("changed")}),
            ),
            AudioTimeline(
                key: audioTimelineKey,
                currentPosition: 0,
                duration: file.getDuration()!,
                loopPoint: 100,
                onChangeStart: (db) async => {
                      if (playButtonKey.currentState!.isPlaying) {togglePlay()},
                      // if (audioTimelineKey.currentState!.isPlaying)
                      //   {
                      //     audioTimelineKey.currentState?.setState(() {
                      //       audioTimelineKey.currentState?.isPlaying = false;
                      //     })
                      //   },
                      // await mpv.pause()
                    },
                onSeek: (value) async {
                  audioTimelineKey.currentState?.sliderValue = value;
                },
                onChangeEnd: (value) async => {
                      // if(mpv.isPlaying){
                      //   await togglePlay()
                      // }
                      // print(audioTimelineKey.currentState!.sliderValue),
                      // if (value <= file.getDuration()!)
                      //   {
                      //     await mpv
                      //         .seek(audioTimelineKey.currentState!.sliderValue),
                      //     if (audioTimelineKey.currentState!.isPlaying)
                      //       {await togglePlay()}
                      //   }
                    },
                onLoopPointChange: (value) {}),
            PlayButton(togglePlay, key: playButtonKey),
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
  State<PlayButton> createState() => PlayButtonState();
}

class PlayButtonState extends State<PlayButton> {
  bool isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.red,
      child: IconButton(
        color: Colors.white,
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () async => {
          isPlaying = await widget.parentTogglePlay() //setState(() => {})
        },
      ),
    );
  }
}
