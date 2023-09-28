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
  int _sampleRate = 0;
  bool _isPlaying = false;
  bool _editLoopointVisibility = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  GlobalKey<PlayButtonState> playButtonKey = GlobalKey();
  GlobalKey<LoopPointTimelineState> loopPointTimelineKey = GlobalKey();
  double _size = 300;
  MPVPlayer mpv = MPVPlayer();
  double zoomMolt = 1;
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
    loopPointTimelineKey.currentState?.setState(() {
      loopPointTimelineKey.currentState?.filechanged(brstm);
    });
  }

  @override
  void initState() {
    file = widget.file;
    mpv.updateInterval = 300;
    mpv.binary = "mpv";
    final String suffix =
        widget.file.getFilePath()!.contains(RegExp(r"_[fF]\.brstm$"))
            ? "_fast"
            : "_normal";
    mpv.pipe = Platform.isWindows
        ? r"\\.\pipe\mpvsocket_CTDM" + suffix
        : "/tmp/mpvsocket_CTDM$suffix";

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

    _loopStart = file.getLoopStart()!;
    _loopEnd = file.getLoopEnd()!;

    _sampleRate = file.getSampleRate()!;
    audioTimelineKey.currentState?.filechanged(file);
    loopPointTimelineKey.currentState?.filechanged(file);

    setState(() {});
  }

  Future<bool> togglePlay({bool? value}) async {
    _isPlaying = value ?? !_isPlaying;
    playButtonKey.currentState?.isPlaying = _isPlaying;

    if (!mpv.getRunningState()) {
      await mpv.start(hangIndefinitely: true);
      //await Future.delayed(const Duration(milliseconds: 300));
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
      await mpv.enableLoop();
      mpv.setLoopPoint(_loopStart / _sampleRate);
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

  void onLoopPointReached() async {
    await mpv.seek(_loopStart / _sampleRate);
  }

  @override
  Widget build(BuildContext context) {
    _size = (MediaQuery.of(context).size.width * 0.20);
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
                left: 40.0 + (_editLoopointVisibility ? 0 : 25), top: 30),
            child: Column(
              children: [
                ElevatedButton(
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
                Visibility(
                    visible: _editLoopointVisibility,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: 200,
                        height: 160,
                        //  color: Colors.amber,
                        child: Column(
                          children: [
                            const Text("zoom"),
                            Stack(
                              children: [
                                const Positioned(
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                  bottom: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "x1",
                                        style: TextStyle(color: Colors.white70),
                                      ), // Aggiungi il testo per il valore minimo
                                      Text(
                                        "x2",
                                      ), // Aggiungi il testo per il valore massimo in minuti
                                    ],
                                  ),
                                ),
                                Slider(
                                  value: zoomMolt,
                                  onChanged: (value) => {
                                    setState(
                                      () => zoomMolt = value,
                                    ),
                                  },
                                  onChangeEnd: (value) => {
                                    audioTimelineKey.currentState?.setState(() {
                                      audioTimelineKey.currentState
                                          ?.updateSize(value * _size);
                                    }),
                                    loopPointTimelineKey.currentState
                                        ?.setState(() {
                                      loopPointTimelineKey.currentState
                                          ?.updateSize(value * _size);
                                    })
                                  },
                                  min: 1,
                                  max: 2,
                                )
                              ],
                            ),
                            Text("Start sample: $_loopStart"),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.amberAccent)),
                                  onPressed: () => {
                                        file.setLoopPointSampleStart(
                                            _loopStart.toInt()),
                                        reset(BRSTM(file.getFilePath()!))
                                      },
                                  child: const Text(
                                    "Save",
                                    style: TextStyle(color: Colors.black87),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80, left: 40, right: 40),
          child: Text(path.basename(widget.file.getFilePath()!)),
        ),
        Padding(
          padding: EdgeInsets.only(left: 25 * zoomMolt * zoomMolt),
          child: Column(
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width * 0.7) * zoomMolt,
                child: const Padding(
                    padding: EdgeInsets.only(bottom: 80, left: 40, right: 40),
                    child: Text("")),
              ),
              Visibility(
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                visible: _editLoopointVisibility,
                child: LoopPointTimeline(
                    size: _size,
                    key: loopPointTimelineKey,
                    startLoop: _loopStart,
                    endLoop: _loopEnd,
                    sampleRate: _sampleRate,
                    onLoopPointChangeEnd: (n) {
                      //file.setLoopPointSampleStart(n.start.toInt());
                    },
                    onLoopPointChange: (n) => {
                          _loopStart = n.toInt(),
                          setState(() => {}),
                        }),
              ),
              AudioTimeline(
                  size: _size * zoomMolt,
                  key: audioTimelineKey,
                  currentPosition: 0,
                  duration: file.getDuration()!,
                  loopPointStart: file.getLoopStart()!,
                  loopPointEnd: file.getLoopEnd()!,
                  sampleRate: file.getSampleRate()!,
                  onLoopPointReached: onLoopPointReached,
                  onChangeStart: (db) async => {
                        if (playButtonKey.currentState!.isPlaying)
                          {togglePlay()},
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
