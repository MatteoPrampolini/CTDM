import 'dart:io';

import 'package:brstm_player/brstm.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/player.dart';
import 'package:ctdm/utils/music_utils.dart';
import 'package:flutter/material.dart';

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
    fileList =
        Directory(widget.folderPath).listSync().whereType<File>().toList();
    super.initState();
  }

  void stopAll() {
    brstmPlayerKey1.currentState?.reset();
    brstmPlayerKey2.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    fileList = [
      Directory(widget.folderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => !isFastBrstm(element.path)),
      Directory(widget.folderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => isFastBrstm(element.path))
    ];

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
