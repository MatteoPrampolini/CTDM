import 'dart:io';

import 'package:brstm_player/brstm.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/player.dart';
import 'package:ctdm/utils/music_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DoubleBrstmPlayer extends StatefulWidget {
  String folderPath;
  DoubleBrstmPlayer(this.folderPath, {super.key});

  @override
  State<DoubleBrstmPlayer> createState() => DoubleBrstmPlayerState();
}

class DoubleBrstmPlayerState extends State<DoubleBrstmPlayer> {
  late List<File> fileList;
  GlobalKey<BrstmPlayerState> brstmPlayerKey1 = GlobalKey();
  GlobalKey<BrstmPlayerState> brstmPlayerKey2 = GlobalKey();

  @override
  void initState() {
    selectedFileChange(widget.folderPath);
    updateFileList(widget.folderPath);
    super.initState();
  }

  @override
  void dispose() async {
    // await brstmPlayerKey1.currentState?.mpv.quit();
    // await brstmPlayerKey2.currentState?.mpv.quit();

    super.dispose();
  }

  selectedFileChange(String subFolderPath) async {
    updateFileList(subFolderPath);
    brstmPlayerKey1.currentState?.reset(BRSTM(fileList[0].path));
    brstmPlayerKey2.currentState?.reset(BRSTM(fileList[1].path));
    brstmPlayerKey1.currentState?.reloadFile();
    brstmPlayerKey2.currentState?.reloadFile();
    setState(() {});
  }

  void updateFileList(subFolderPath) {
    fileList = [
      Directory(subFolderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => !isFastBrstm(element.path)),
      Directory(subFolderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => isFastBrstm(element.path))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BrstmPlayer(BRSTM(fileList[0].path), key: brstmPlayerKey1),
        const Divider(),
        BrstmPlayer(BRSTM(fileList[1].path), key: brstmPlayerKey2)
      ],
    );
  }
}
