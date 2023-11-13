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
  bool _isSeeking = false;
  bool _showTextFieldCursor = false;
  // bool _editLoopointVisibility = false;
  GlobalKey<AudioTimelineState> audioTimelineKey = GlobalKey();
  GlobalKey<PlayButtonState> playButtonKey = GlobalKey();
  GlobalKey<LoopPointTimelineState> loopPointTimelineKey = GlobalKey();
  double _size = 300;
  MPVPlayer mpv = MPVPlayer();
  double zoomMolt = 2.5;
  final TextEditingController _loopStartController = TextEditingController();
  bool _loopIsValid = false;
  int volume = 100;
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
    _loopStart = file.getLoopStart()!;
    _loopEnd = file.getLoopEnd()!;
    _loopStartController.text = _loopStart.toString();
    setState(() {});
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
    _loopStartController.text = _loopStart.toString();
    setState(() {});
  }

  Future<bool> togglePlay({bool? value}) async {
    _isPlaying = value ?? !_isPlaying;
    playButtonKey.currentState?.isPlaying = _isPlaying;

    if (!mpv.getRunningState()) {
      await mpv.start(hangIndefinitely: true);
      await Future.delayed(const Duration(milliseconds: 300));
      await mpv.volume(volume);
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
      if (!mpv.getPlayerState()) {
        await mpv.loadFile(file.getFilePath()!);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (audioTimelineKey.currentState!.sliderValue > 0) {
        await mpv.pause();
        //await Future.delayed(const Duration(milliseconds: 300));
        await mpv.seek(audioTimelineKey.currentState!.sliderValue);
        //await Future.delayed(const Duration(milliseconds: 300));
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
    _loopIsValid =
        validateInputStartLoopPoint(_loopStartController.text, _loopEnd);
    _size = (MediaQuery.of(context).size.width * 0.20);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20.0, right: 20),
        child: Stack(
          //alignment: Alignment.bottomCenter,
          children: [
            // Align(
            //   alignment: Alignment.bottomLeft,
            //   child: Padding(
            //     padding: EdgeInsets.only(
            //         left: 40.0 + (_editLoopointVisibility ? 0 : 25), top: 30),
            //     child: Column(
            //       children: [
            //         ElevatedButton(
            //             style: ButtonStyle(
            //                 backgroundColor: MaterialStateProperty.all<Color>(
            //                     Colors.amberAccent)), // Change the color here,
            //             onPressed: () => {
            //                   setState(() {
            //                     _editLoopointVisibility = !_editLoopointVisibility;
            //                   })
            //                 },
            //             child: const Text(
            //               "Edit loop point",
            //               style: TextStyle(color: Colors.black87),
            //             )),
            //         Visibility(
            //             visible: _editLoopointVisibility,
            //             child: Padding(
            //               padding: const EdgeInsets.only(top: 20.0),
            //               child: SizedBox(
            //                 width: 200,
            //                 height: 160,
            //                 //  color: Colors.amber,
            //                 child: Column(
            //                   children: [
            //                     const Text("zoom"),
            //                     // Stack(
            //                     //   children: [
            //                     //     const Positioned(
            //                     //       left: 20,
            //                     //       right: 20,
            //                     //       top: 20,
            //                     //       bottom: 0,
            //                     //       child: Row(
            //                     //         mainAxisAlignment:
            //                     //             MainAxisAlignment.spaceBetween,
            //                     //         children: [
            //                     //           Text(
            //                     //             "x1",
            //                     //             style: TextStyle(color: Colors.white70),
            //                     //           ), // Aggiungi il testo per il valore minimo
            //                     //           Text(
            //                     //             "x2",
            //                     //           ), // Aggiungi il testo per il valore massimo in minuti
            //                     //         ],
            //                     //       ),
            //                     //     ),
            //                     //     Slider(
            //                     //       value: zoomMolt,
            //                     //       onChanged: (value) => {
            //                     //         setState(
            //                     //           () => zoomMolt = value,
            //                     //         ),
            //                     //       },
            //                     //       onChangeEnd: (value) => {
            //                     //         audioTimelineKey.currentState?.setState(() {
            //                     //           audioTimelineKey.currentState
            //                     //               ?.updateSize(value * _size);
            //                     //         }),
            //                     //         loopPointTimelineKey.currentState
            //                     //             ?.setState(() {
            //                     //           loopPointTimelineKey.currentState
            //                     //               ?.updateSize(value * _size);
            //                     //         })
            //                     //       },
            //                     //       min: 1,
            //                     //       max: 2,
            //                     //     )
            //                     //   ],
            //                     // ),
            //                     Text("Loop at: $_loopStart"),
            //                     Padding(
            //                       padding: const EdgeInsets.only(top: 25.0),
            //                       child: ElevatedButton(
            //                           style: const ButtonStyle(
            //                               backgroundColor: MaterialStatePropertyAll(
            //                                   Colors.amberAccent)),
            //                           onPressed: () => {
            //                                 file.setLoopPointSampleStart(
            //                                     _loopStart.toInt()),
            //                                 reset(BRSTM(file.getFilePath()!))
            //                               },
            //                           child: const Text(
            //                             "Save",
            //                             style: TextStyle(color: Colors.black87),
            //                           )),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ))
            //       ],
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 80, left: 40, right: 40),
            //   child: Text(path.basename(widget.file.getFilePath()!)),
            // ),

            Text(
              path.basename(widget.file.getFilePath()!),
              style: const TextStyle(color: Colors.white70),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width * 0.7) * zoomMolt,
                    child: const Text(""),
                  ),
                  LoopPointTimeline(
                      size: _size * zoomMolt,
                      key: loopPointTimelineKey,
                      startLoop: _loopStart,
                      endLoop: _loopEnd,
                      sampleRate: _sampleRate,
                      onLoopPointChangeEnd: (n) {
                        _loopStartController.text = n.toInt().toString();
                        _loopIsValid = true;
                        //file.setLoopPointSampleStart(n.start.toInt());
                      },
                      onLoopPointChange: (n) => {
                            _loopStart = n.toInt(),
                            setState(() => {}),
                          }),
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
                              {
                                togglePlay(),
                                _isSeeking = true,
                              },
                          },
                      onSeek: (value) async {
                        audioTimelineKey.currentState?.sliderValue = value;
                      },
                      onChangeEnd: (value) async => {
                            if (_isSeeking)
                              {
                                togglePlay(value: true),
                                _isSeeking = false,
                              }
                          },
                      onLoopPointChange: (value) {}),
                  PlayButton(togglePlay, key: playButtonKey),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 50,
                            child: TextField(
                              autofocus: false,
                              showCursor: _showTextFieldCursor,
                              onTap: () => {
                                _showTextFieldCursor = true,
                                setState(
                                  () => {},
                                )
                              },
                              onChanged: (value) => {
                                _loopIsValid = validateInputStartLoopPoint(
                                    value, _loopEnd),
                              },
                              onEditingComplete: () => {
                                if (_loopIsValid)
                                  {
                                    _loopStart =
                                        int.parse(_loopStartController.text),
                                    mpv.setLoopPoint(_loopStart / _sampleRate),
                                    loopPointTimelineKey.currentState
                                        ?.setState(() {
                                      loopPointTimelineKey.currentState
                                          ?.updateLoopPoint(_loopStart);
                                    }),
                                    audioTimelineKey.currentState?.setState(() {
                                      audioTimelineKey.currentState
                                          ?.updateLoopPoint(_loopStart);
                                    })
                                  },
                              },
                              onTapOutside: (event) => {
                                _showTextFieldCursor = false,
                                setState(
                                  () => {},
                                ),
                                if (_loopIsValid)
                                  {
                                    _loopStart =
                                        int.parse(_loopStartController.text),
                                    mpv.setLoopPoint(_loopStart / _sampleRate),
                                    loopPointTimelineKey.currentState
                                        ?.setState(() {
                                      loopPointTimelineKey.currentState
                                          ?.updateLoopPoint(_loopStart);
                                    }),
                                    audioTimelineKey.currentState?.setState(() {
                                      audioTimelineKey.currentState
                                          ?.updateLoopPoint(_loopStart);
                                    })
                                  },
                              },
                              controller: _loopStartController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: Colors.amberAccent, fontSize: 16),
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.amber)),
                                hintText: 'Loop sample',
                                hintStyle: const TextStyle(color: Colors.grey),
                                errorStyle:
                                    const TextStyle(color: Colors.amberAccent),
                                errorText: _loopIsValid ? null : "Invalid",
                              ),
                            ),
                          ),
                          const Text(
                            '/',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20),
                          ),
                          Text(
                            _loopEnd.toString(),
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16), // Colore giallo
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: IconButton(
                                iconSize: 30,
                                icon: const Icon(Icons.published_with_changes),
                                tooltip: "Override file",
                                color: Colors.amberAccent,
                                onPressed: () => {
                                  file.setLoopPointSampleStart(
                                      _loopStart.toInt()),
                                  _showResultModal(context, file.getFilePath()!)
                                },
                              ) // )),
                              ),
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

String formatDuration(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;

  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}

bool validateInputStartLoopPoint(String value, int loopEnd) {
  // Aggiungi qui la tua logica di validazione
  // Ritorna true se l'input è valido, altrimenti false
  try {
    int parsedValue = int.parse(value);
    // Puoi aggiungere ulteriori regole di validazione qui se necessario
    if (parsedValue < 0 || parsedValue >= loopEnd) {
      return false;
    }
    return true; // Ad esempio, accetta solo valori non negativi
  } catch (e) {
    return false; // Se non è possibile convertire in un numero intero, considera l'input non valido
  }
}

void _showResultModal(BuildContext context, String filePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "File saved",
          style: TextStyle(color: Colors.amberAccent),
        ),
        content: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(path.basename(filePath), maxLines: 2)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
