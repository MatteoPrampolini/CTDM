import 'dart:io';

import 'package:ctdm/drawer_options/brstm_player.dart/double_brstm_player.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;

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

  bool addFileVisibile = false;
  @override
  void initState() {
    super.initState();
    myMusicFolder =
        path.join(path.dirname(path.dirname(widget.packPath)), 'myMusic');
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
        body: Stack(children: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 20.0),
          //   child: Align(
          //     alignment: Alignment.topCenter,
          //     child: Text("myMusic",
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //             fontSize: Theme.of(context)
          //                 .textTheme
          //                 .headlineMedium
          //                 ?.fontSize)),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.amberAccent)),
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
                      doublePlayerKey.currentState?.stopAll(),
                      setState(
                        () => selectedFolder = i,
                      )
                    },
                  ),
                IconButton(
                    onPressed: () => {
                          setState(() => addFileVisibile = !addFileVisibile),
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
              child: DropTarget(
                  child: SizedBox.expand(
                      child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 5 + 5,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Drop file Here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.redAccent,
                                  decoration: TextDecoration.underline),
                            ),
                            const Icon(Icons.audio_file_outlined,
                                color: Colors.redAccent, size: 48),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Text("or"),
                            ),
                            ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  "Browse files",
                                  style: TextStyle(fontSize: 24),
                                ))
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
                child: DoubleBrstmPlayer(
                  folderList[selectedFolder].path,
                  key: doublePlayerKey,
                ),
              ))))
        ]));
  }
}
