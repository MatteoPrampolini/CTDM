import 'dart:io';

import 'package:ctdm/drawer_options/brstm_player.dart/double_brstm_player.dart';
import 'package:ctdm/utils/music_utils.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MusicEditor extends StatefulWidget {
  String packPath;
  MusicEditor(this.packPath, {super.key});

  @override
  State<MusicEditor> createState() => _MusicEditorState();
}

class _MusicEditorState extends State<MusicEditor> {
  List<Directory> folderList = [];
  int selectedFolder = 0;
  late String myMusicFolder;
  GlobalKey<DoubleBrstmPlayerState> doublePlayerKey = GlobalKey();
  FilePickerResult? musicFileResult;
  bool addFileVisibile = false;
  bool _isConverting = false;
  double volume = 100;
  //File? file;
  @override
  void initState() {
    super.initState();
    myMusicFolder =
        path.join(path.dirname(path.dirname(widget.packPath)), 'myMusic');
  }

  Future<void> createBrstmFromAudioSource(File? audiofile) async {
    if (audiofile == null) {
      return;
    }
    setState(() {
      _isConverting = true;
    });

    String myMusicPath =
        path.join(path.dirname(path.dirname(widget.packPath)), 'myMusic');
    await audioFileToBrstmPair(
      audiofile,
      path.join(myMusicPath, path.basenameWithoutExtension(audiofile.path)),
    );
    setState(() {
      _isConverting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    folderList =
        Directory(myMusicFolder).listSync().whereType<Directory>().toList();

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Music editor",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: !(isMpvInstalled() && isFfmpegInstalled())
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isMpvInstalled()
                      ? const Text("")
                      : const Text(
                          "ERROR: MPV NOT INSTALLED",
                          style: TextStyle(color: Colors.white54, fontSize: 30),
                        ),
                  isMpvInstalled()
                      ? const Text("")
                      : TextButton(
                          onPressed: () => {
                            launchUrl(Uri.parse('https://mpv.io/')),
                          },
                          child: const Text(
                            "Download",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 30,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: isFfmpegInstalled()
                        ? const Text("")
                        : const Text(
                            "ERROR: FFMPEG NOT INSTALLED",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 30),
                          ),
                  ),
                  isFfmpegInstalled()
                      ? const Text("")
                      : TextButton(
                          onPressed: () => {
                            launchUrl(
                                Uri.parse('https://ffmpeg.org/download.html')),
                          },
                          child: const Text(
                            "Download",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 30,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "After installing add the executables to path",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: () => {
                        launchUrl(Uri.parse(
                            'https://wiki.tockdom.com/wiki/CTDM_Tutorial#Installation')),
                      },
                      child: const Text(
                        "Read the wiki",
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
            : Stack(children: [
                Positioned(
                  right: 20,
                  top: 20,
                  width: 40,
                  height: 240,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const RotatedBox(
                            quarterTurns: 1,
                            child: Icon(
                              Icons.volume_off,
                              color: Colors.white70,
                            )),
                        Slider(
                            min: 0,
                            max: 100,
                            value: volume,
                            onChangeEnd: (value) {
                              doublePlayerKey.currentState
                                  ?.setVolume(volume.toInt());
                              setState(() {
                                volume = value;
                              });
                            },
                            onChanged: (newValue) {
                              setState(
                                () {
                                  volume = newValue;
                                },
                              );
                            }),
                        const RotatedBox(
                            quarterTurns: 1,
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.white70,
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.amberAccent)),
                    height: MediaQuery.of(context).size.height - 30,
                    width: MediaQuery.of(context).size.width / 5,
                    child: SingleChildScrollView(
                        child: Column(children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text("FOLDER LIST",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 30,
                            )),
                      ),
                      const Divider(),
                      for (int i = 0; i < folderList.length; i++)
                        ListTile(
                          leading: const Icon(Icons.chevron_right),
                          selected: i == selectedFolder,
                          title: Text(
                            path.basename(folderList[i].path),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          onTap: () => {
                            addFileVisibile = false,
                            selectedFolder = i,
                            doublePlayerKey.currentState?.selectedFileChange(
                                folderList[selectedFolder].path,
                                volume: volume.toInt()),
                            setState(() => {})
                          },
                        ),
                      IconButton(
                          onPressed: () => {
                                setState(
                                    () => addFileVisibile = !addFileVisibile),
                              },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.amberAccent,
                          ))
                    ])),
                  ),
                ),
                Visibility(
                  visible: addFileVisibile,
                  child: Center(
                    child: _isConverting
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 5,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              heightFactor: 0.3,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  LoadingAnimationWidget.fourRotatingDots(
                                      color: Colors.redAccent, size: 150),
                                  const Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        "Converting to .brstm\nPlease wait...",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 20),
                                      )),
                                ],
                              ),
                            ),
                          )
                        : DropTarget(
                            enable: true,
                            onDragDone: (details) async => {
                                  if (details.files.isNotEmpty)
                                    {
                                      if (details.files[0].name
                                          .contains(RegExp(r'\.(mp3|wav)$')))
                                        {
                                          await createBrstmFromAudioSource(
                                              File(details.files[0].path))
                                        }
                                      else
                                        {
                                          _showErrorDialog(context,
                                              "Invalid Extension. Only MP3/WAV allowed.")
                                        }
                                    }
                                },
                            child: SizedBox.expand(
                                child: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 5 + 5,
                                  top: 5,
                                  bottom: 5,
                                  right: 5),
                              child: DottedBorder(
                                color: Colors.redAccent,
                                strokeWidth: 1,
                                dashPattern: const [10, 10, 10, 10],
                                borderPadding: const EdgeInsets.all(8),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black38,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Drop file Here",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 48,
                                                color: Colors.redAccent,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                          const Icon(Icons.audio_file_outlined,
                                              color: Colors.redAccent,
                                              size: 48),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 40.0),
                                            child: Text("or"),
                                          ),
                                          ElevatedButton(
                                              onPressed: () async => {
                                                    musicFileResult = await FilePicker
                                                        .platform
                                                        .pickFiles(
                                                            allowMultiple:
                                                                false,
                                                            allowedExtensions: [
                                                              'mp3',
                                                              'wav',
                                                            ],
                                                            type:
                                                                FileType.custom,
                                                            initialDirectory:
                                                                path.join(
                                                                    widget
                                                                        .packPath,
                                                                    '..',
                                                                    '..',
                                                                    'myMusic')),
                                                    if (musicFileResult != null)
                                                      {
                                                        await createBrstmFromAudioSource(
                                                            File(
                                                                musicFileResult!
                                                                    .files
                                                                    .first
                                                                    .path!))
                                                      }
                                                  },
                                              child: const Text("Browse files",
                                                  style:
                                                      TextStyle(fontSize: 24)))
                                        ],
                                      ),
                                    )),
                              ),
                            ))),
                  ),
                ),
                Visibility(
                    visible: !addFileVisibile,
                    child: Center(
                        child: SizedBox.expand(
                            child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 5 + 5,
                          top: 5,
                          bottom: 5,
                          right: 5),
                      child: folderList.isNotEmpty
                          ? DoubleBrstmPlayer(
                              folderList[selectedFolder].path,
                              key: doublePlayerKey,
                            )
                          : const Center(
                              child: Text(
                              "myMusic folder is empty.",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 20),
                            )),
                    ))))
              ]));
  }
}

void _showErrorDialog(BuildContext context, String result) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "ERROR",
          style: TextStyle(color: Colors.redAccent),
        ),
        content:
            FittedBox(fit: BoxFit.fitWidth, child: Text(result, maxLines: 2)),
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
