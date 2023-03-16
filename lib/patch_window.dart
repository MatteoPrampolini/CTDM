import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PatchWindow extends StatefulWidget {
  final String packPath;
  const PatchWindow(this.packPath, {super.key});

  @override
  State<PatchWindow> createState() => _PatchWindowState();
}

List<String> checkTracklistInFolder(List<String> trackList, String trackPath) {
  Directory myTracks = Directory(trackPath);
  List<FileSystemEntity> fsTracks = myTracks.listSync(recursive: true);
  List<String> fsTracksPaths = [];
  List<String> missingFiles = [];
  for (FileSystemEntity track in fsTracks) {
    fsTracksPaths.add(path.basenameWithoutExtension(track.path));
  }
  for (var configTrack in trackList) {
    if (!fsTracksPaths.contains(configTrack)) {
      missingFiles.add(configTrack);
    }
  }
  return missingFiles;
}

List<String> getTracksFilenamesFromConfig(String packPath) {
  List<String> dirtyTrackFilenames = [];
  List<String> trackFilenames = [];
  File configFile = File(path.join(packPath, 'config.txt'));
  String contents = configFile.readAsStringSync();
  contents = contents.split(r'N N$SWAP | N$F_WII')[1];

  dirtyTrackFilenames = contents.split('\n');
  for (var dirty in dirtyTrackFilenames) {
    if (';'.allMatches(dirty).length == 5 && !dirty.contains((r'0x04;'))) {
      trackFilenames.add(dirty.split(';')[3].replaceAll(r'"', '').trimLeft());
    }
  }
  return trackFilenames;
}

List<String> parseBMGList(String packPath) {
  File trackFile = File(path.join(packPath, 'tracks.bmg.txt'));
  String contents = trackFile.readAsStringSync();
  contents = contents
      .split(RegExp(r'7045.= '))[1]
      .replaceAll(RegExp(r'[0-9]+.= '), '');
  List<String> tracksDirty = contents.split('\n');
  List<String> cleanTracks = [];
  for (var track in tracksDirty) {
    cleanTracks.add(track.trim());
  }
  cleanTracks.removeWhere((element) => element.isEmpty);
  return cleanTracks;
}

Future<List<String>> createBMGList(String packPath) async {
  //genera tracks.bmg.txt
  File trackFile = File(path.join(packPath, 'tracks.bmg.txt'));
  if (trackFile.existsSync()) {
    trackFile.deleteSync();
  }
  try {
    final process = await Process.start(
        'wctct',
        [
          'create',
          'bmg',
          '--le-code',
          '--long',
          path.join(packPath, 'config.txt'),
          '--dest',
          path.join(packPath, 'tracks.bmg.txt')
        ],
        runInShell: false);
    final _ = await process.exitCode;
    return parseBMGList(packPath);
  } on Exception catch (_) {
    return [];
  }

  //2 leggi tracks.bmg.txt da 7044
  //3 controlla che i nomi siano nella cartella MyTracks
}

class _PatchWindowState extends State<PatchWindow> {
  late List<String> missingTracks = [];
  @override
  void initState() {
    patch(widget.packPath);
    super.initState();
  }

  void patch(String packPath) async {
    String workspace = path.dirname(path.dirname(packPath));
    List<String> trackList = getTracksFilenamesFromConfig(packPath);
    setState(() {
      missingTracks =
          checkTracklistInFolder(trackList, path.join(workspace, 'MyTracks'));
    });
    // missingTracks =
    //     checkTracklistInFolder(trackList, path.join(workspace, 'MyTracks'));

    if (missingTracks.isNotEmpty) {
      print(missingTracks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Patch window",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Center(
            child: Column(children: [
          Text("patching..."),
          Expanded(
              child: ListView.builder(
                  itemCount: missingTracks.length,
                  itemBuilder: (context, index) {
                    return Text(missingTracks[index]);
                  }))
        ])));
  }
}
