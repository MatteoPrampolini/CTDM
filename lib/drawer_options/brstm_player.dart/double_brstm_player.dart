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
  List<File> fileList = [];
  GlobalKey<BrstmPlayerState> brstmPlayerKey1 = GlobalKey();
  GlobalKey<BrstmPlayerState> brstmPlayerKey2 = GlobalKey();

  @override
  void initState() {
    selectedFileChange(widget.folderPath, volume: 100);
    updateFileList(widget.folderPath);
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Future<void> setVolume(int volume) async {
    brstmPlayerKey1.currentState?.volume = volume;
    brstmPlayerKey2.currentState?.volume = volume;

    await brstmPlayerKey1.currentState?.mpv.volume(volume);
    await brstmPlayerKey2.currentState?.mpv.volume(volume);
  }

  selectedFileChange(String subFolderPath, {int? volume}) async {
    updateFileList(subFolderPath);

    if (fileList.isNotEmpty) {
      brstmPlayerKey1.currentState?.reset(BRSTM(fileList[0].path));
    }
    if (fileList.length > 1) {
      brstmPlayerKey2.currentState?.reset(BRSTM(fileList[1].path));
    }
    // brstmPlayerKey1.currentState?.reloadFile();
    // brstmPlayerKey2.currentState?.reloadFile();
    if (volume != null) {
      setVolume(volume);
    }
    setState(() {});
  }

  void updateFileList(subFolderPath) {
    fileList = [];
    File? normal;
    File? fast;

    try {
      normal = Directory(subFolderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => !isFastBrstm(element.path));
      fileList.add(normal);
    } on StateError catch (_) {
      normal = null;
    }
    try {
      fast = Directory(subFolderPath)
          .listSync()
          .whereType<File>()
          .firstWhere((element) => isFastBrstm(element.path));
      fileList.add(fast);
    } on StateError catch (_) {
      fast = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        fileList.isNotEmpty
            ? BrstmPlayer(BRSTM(fileList[0].path), key: brstmPlayerKey1)
            : const Expanded(child: Center(child: Text("normal file missing"))),
        const Divider(),
        fileList.length > 1
            ? BrstmPlayer(BRSTM(fileList[1].path), key: brstmPlayerKey2)
            : const Expanded(child: Center(child: Text("fast file missing"))),
      ],
    );
  }
}
