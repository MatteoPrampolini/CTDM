import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class PatchWindow extends StatefulWidget {
  final String packPath;
  const PatchWindow(this.packPath, {super.key});

  @override
  State<PatchWindow> createState() => _PatchWindowState();
}

enum PatchingStatus { aborted, running, completed }

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

void wipeOldFiles(String packPath) {
  try {
    if (Directory(path.join(packPath, 'Race', 'Course')).existsSync()) {
      Directory(path.join(packPath, 'Race', 'Course'))
          .deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'Race', 'Common')).existsSync()) {
      Directory(path.join(packPath, 'Race', 'Common'))
          .deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'rel')).existsSync()) {
      Directory(path.join(packPath, 'rel')).deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'Scene')).existsSync()) {
      Directory(path.join(packPath, 'Scene')).deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'sys')).existsSync()) {
      Directory(path.join(packPath, 'sys')).deleteSync(recursive: true);
    }
  } catch (_) {}
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

Future<String> createBMGList(String packPath) async {
  //genera tracks.bmg.txt
  File trackFile = File(path.join(packPath, 'Scene', 'tracks.bmg.txt'));
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
          path.join(packPath, 'Scene', 'tracks.bmg.txt')
        ],
        runInShell: false);
    final _ = await process.exitCode;
    //return parseBMGList(packPath);
  } on Exception catch (_) {
    //return [];
  }
  return path.join(packPath, 'Scene', 'tracks.bmg.txt');
  //2 leggi tracks.bmg.txt da 7044
  //3 controlla che i nomi siano nella cartella MyTracks
}

Future<void> editMenuSingle(String workspace, String packPath) async {
  //1 copia menusingle_E
  //2 crea track.bmg.txt
  //3 decoda menusingle_E.szs-> common.txt
  //4 szs->folder
  //5 edita common.txt
  //6 encoda common.txt -> common.bmg (piazzato in folder)
  //7 folder ->szs

  //1
  final File origMenuFile = File(path.join(
      workspace, 'ORIGINAL_DISC', 'files', 'Scene', 'UI', 'MenuSingle_E.szs'));
  origMenuFile.copySync(path.join(packPath, 'Scene', 'MenuSingle_E.szs'));
  //2
  String bmgFilePath = await createBMGList(packPath);
  final File trackBmgTxt = File(bmgFilePath);
  //3
  try {
    //  wbmgt decode MenuSingle_E.szs
    final process = await Process.start(
        'wbmgt',
        [
          'decode',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.txt'),
        ],
        runInShell: false);
    final _ = await process.exitCode;
  } on Exception catch (_) {}

  //4
  try {
    // wszst extract MenuSingle_E.szs
    final process = await Process.start(
        'wszst',
        [
          'extract',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.d'),
        ],
        runInShell: false);
    final _ = await process.exitCode;
  } on Exception catch (_) {}
  //5
  String contents = trackBmgTxt.readAsStringSync();
  contents = contents.replaceAll(RegExp(r'#BMG'), '');
  File editedMenuFile = File(path.join(packPath, 'Scene', 'MenuSingle_E.txt'));
  editedMenuFile.writeAsString(contents, mode: FileMode.append);
  //6
  try {
    //  wbmgt encode MenuSingle_E.txt
    final process = await Process.start(
        'wbmgt',
        [
          'encode',
          path.join(packPath, 'Scene', 'MenuSingle_E.txt'),
          '--overwrite',
          '--dest',
          path.join(
              packPath, 'Scene', 'MenuSingle_E.d', 'message', 'Common.bmg'),
        ],
        runInShell: false);
    final _ = await process.exitCode;
  } on Exception catch (_) {}
  //7
  try {
    final process = await Process.start(
        'wszst',
        [
          'create',
          path.join(packPath, 'Scene', 'MenuSingle_E.d'),
          '--overwrite',
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
        ],
        runInShell: false);
    final _ = await process.exitCode;
  } on Exception catch (_) {}

  //delete all tmp file
}

void singleTrackCopy(String workspace, String packPath, String szsPath) {
  bool isDir = path.basename(path.dirname(szsPath)) != "myTracks";
  if (isDir) {
    //print("$szsPath is in subdir");

    //guarda il suo id da tracks.bmg.txt
    String id = getIdFromTracksBmgTxt(
        path.join(packPath, 'Scene', 'tracks.bmg.txt'),
        path.basenameWithoutExtension(szsPath));
    //print(id);

    Directory(path.join(packPath, 'Race', 'Common', id)).createSync();

    Directory(path.dirname(szsPath))
        .listSync()
        .whereType<File>()
        .forEach((file) {
      if (file.path.endsWith('.bin')) {
        file.copySync(path.join(
            packPath, 'Race', 'Common', id, path.basename(file.path)));
      }
    });
    //sposta tutti i file tranne il file szs in Race/Common/xxx/
  } else {
    //print("$szsPath is single file");
  }
  File(szsPath)
      .copySync(path.join(packPath, 'Race', 'Course', path.basename(szsPath)));
}

String getIdFromTracksBmgTxt(String bmgTxtPath, String trackName) {
  List<String> lines = File(bmgTxtPath).readAsLinesSync();
  for (var line in lines) {
    if (line.contains(trackName)) {
      return line.trim().replaceRange(0, 1, '').replaceRange(3, null, '');
    }
  }
  return "ID NOT FOUND";
}

void copyMyTracksToCourseFolder(
    String workspace, String packPath, List<String> configTrackList) {
  Directory myTracksDir = Directory(path.join(workspace, 'myTracks'));
  //List<FileSystemEntity> myTracksList = myTracksDir.listSync(recursive: true).;
  List<String> myTrackList = myTracksDir
      .listSync(recursive: true)
      .whereType<File>()
      .map((e) => e.path)
      .toList();
  //controllo che il nome base senza est della trackList sia nella directory myTrackList
  for (var configTrack in configTrackList) {
    if (myTrackList
        .map((e) => path.basenameWithoutExtension(e))
        .toList()
        .contains(configTrack)) {
      singleTrackCopy(
          workspace,
          packPath,
          myTrackList.firstWhere((element) =>
              path.basenameWithoutExtension(element) == configTrack));
    } else {
      //print("non trovato"); //impossible?
    }
  }
}

class _PatchWindowState extends State<PatchWindow> {
  late List<String> missingTracks = [];
  PatchingStatus patchStatus = PatchingStatus.running;
  @override
  void initState() {
    patch(widget.packPath);
    super.initState();
  }

  void updateXMl(String pathPack, String isoVersion) {}
  void patch(String packPath) async {
    patchStatus = PatchingStatus.running;
    //1 CHECK TRACKS FILES
    //wipeOldFiles(packPath);
    String workspace = path.dirname(path.dirname(packPath));
    List<String> trackList = getTracksFilenamesFromConfig(packPath);
    setState(() {
      missingTracks =
          checkTracklistInFolder(trackList, path.join(workspace, 'MyTracks'));
    });

    if (missingTracks.isNotEmpty) {
      patchStatus = PatchingStatus.aborted;
      return;
    }
    //2 EDIT MENU_SINGLE
    await editMenuSingle(workspace, packPath);
    Directory(path.join(packPath, 'Scene', 'MenuSingle_E.d'))
        .delete(recursive: true);
    //3 COPY TRACKS from MyTracks, only the one specified by trackList
    copyMyTracksToCourseFolder(workspace, packPath, trackList);
    File(path.join(packPath, 'Scene', 'MenuSingle_E.txt')).delete();
    File(path.join(packPath, 'Scene', 'tracks.bmg.txt')).delete();
    //4 FINALLY PATCHING
    //4a)copy lecode-VER.bin in rel
    //4b)wlect patch lecode-PAL.bin -od lecode-PAL.bin --le-define config.txt --track-dir .
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String isoVersion = prefs.getString('isoVersion')!;
    File("assets/lecode_build/lecode-$isoVersion.bin")
        .copySync(path.join(packPath, 'rel', "lecode-$isoVersion.bin"));
    try {
      //  wlect patch lecode-PAL.bin -od lecode-PAL.bin --le-define config.txt --track-dir .
      final process = await Process.start(
          'wlect',
          [
            'patch',
            path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
            '--overwrite',
            '--dest',
            path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
            '--le-define',
            path.join(packPath, 'config.txt'),
            '--track-dir',
            path.join(packPath, 'Race', 'Course'),
            '--move-tracks',
            path.join(packPath, 'Race', 'Course'),
          ],
          runInShell: false);
      final _ = await process.exitCode;
    } on Exception catch (_) {
      print(_);
    }
    try {
      // wlect patch lecode-PAL.bin --lpar lpar.txt
      final process = await Process.start(
          'wlect',
          [
            'patch',
            path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
            '--overwrite',
            '--dest',
            path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
            '--lpar',
            path.join(packPath, 'lpar.txt'),
          ],
          runInShell: false);
      final _ = await process.exitCode;
    } on Exception catch (_) {
      print(_);
    }
    //move main.dol and patch it
    File(path.join(workspace, 'ORIGINAL_DISC', 'sys', 'main.dol'))
        .copySync(path.join(packPath, 'sys', 'main.dol'));
    try {
      // wstrt patch --add-lecode main.dol
      final process = await Process.start(
          'wstrt',
          [
            'patch',
            '--add-lecode',
            path.join(packPath, 'sys', 'main.dol'),
            '--overwrite',
            '--dest',
            path.join(packPath, 'sys', 'main.dol'),
          ],
          runInShell: false);
      final _ = await process.exitCode;
    } on Exception catch (_) {
      print(_);
    }
    updateXMl(packPath, isoVersion);
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
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Center(child: Text("patching...")),
              Visibility(
                visible: missingTracks.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Wrap(
                    children: [
                      Center(
                        child: Text(
                          "ERROR: TRACK FILES NOT FOUND",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              backgroundColor: Colors.red,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  ?.fontSize),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "the following tracks were not found in MyTracks folder:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.fontSize),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: missingTracks.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        color: Colors.amber.shade300,
                                        border: Border.all(
                                            color: Colors.black,
                                            strokeAlign: StrokeAlign.center)),
                                    child: SelectableText(
                                      "${missingTracks[index]}.szs",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: patchStatus == PatchingStatus.aborted,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 120.0),
                              child: Text(
                                "the patching process has been stopped.",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.fontSize),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              )
            ])));
  }
}
