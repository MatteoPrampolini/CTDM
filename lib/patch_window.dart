import 'dart:convert';
import 'dart:io';

import 'package:ctdm/utils/exceptions_utils.dart';
import 'package:ctdm/utils/xml_json_utils.dart';
import 'dart:ui' as ui;
import 'package:ctdm/drawer_options/cup_icons.dart';
import 'package:ctdm/drawer_options/multiplayer.dart';
import 'package:ctdm/drawer_options/track_config_gui.dart';
import 'package:ctdm/gui_elements/types.dart';
import 'package:ctdm/utils/bmg_utils.dart';
import 'package:ctdm/utils/character_utiles.dart';
import 'package:ctdm/utils/filepath_utils.dart';
import 'package:ctdm/utils/gecko_utils.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:ctdm/utils/music_utils.dart';
import 'package:ctdm/utils/output_utils.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merge_images/merge_images.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer_options/custom_files.dart';

class PatchWindow extends StatefulWidget {
  final String packPath;
  final bool? fastPatch;
  const PatchWindow(this.packPath, {super.key, this.fastPatch});

  @override
  State<PatchWindow> createState() => _PatchWindowState();
}

enum PatchingStatus { aborted, running, completed }

/// Returns a list of lists, one containing the track names and the other containing their respective paths, for tracks that use common files.
List getTracksDirWithCommons(String myTrackPath, List<String> configTrack) {
  Directory myTracks = Directory(myTrackPath);
  List<Directory> fsTracksFolder =
      myTracks.listSync(recursive: false).whereType<Directory>().toList();

  List<String> baseNameWithCommonList = [];
  List<String> commonDirpathList = [];
  for (Directory folder in fsTracksFolder) {
    List<File> tmpFileList = folder.listSync().whereType<File>().toList();

    for (String track in configTrack) {
      if (tmpFileList
          .map((e) => path.basenameWithoutExtension(e.path))
          .contains(track)) {
        baseNameWithCommonList.add(track);
        commonDirpathList.add(path.dirname(tmpFileList
            .firstWhere((element) =>
                path.basenameWithoutExtension(element.path).contains(track))
            .path));
      }
    }
  }
  return [baseNameWithCommonList, commonDirpathList];
}

/// Checks whether the files listed in [trackList] are actually present in the [trackPath] directory.
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

///Checks if all necessary folders exist inside the [packPath] and creates them if they don't.
void createFolders(String packPath) {
  if (!Directory(path.join(packPath, 'thp')).existsSync()) {
    Directory(path.join(
      packPath,
      'thp',
    )).createSync();
    final File emptyVideo = File(path.join(
        path.dirname(Platform.resolvedExecutable),
        "data",
        "flutter_assets",
        "assets",
        "misc",
        "empty.thp"));
    emptyVideo.copy(path.join(packPath, 'thp', 'empty.thp'));
  }
  if (!Directory(path.join(packPath, 'myStuff')).existsSync()) {
    Directory(path.join(packPath, 'myStuff')).createSync();
  }
  if (!Directory(path.join(packPath, 'misc')).existsSync()) {
    Directory(path.join(packPath, 'misc')).createSync();
  }
  if (!File(path.join(packPath, 'misc.txt')).existsSync()) {
    File(path.join(packPath, 'misc.txt')).createSync();
  }
  if (!Directory(path.join(packPath, 'extra')).existsSync()) {
    Directory(path.join(packPath, 'extra')).createSync();
  }
  if (Directory(path.join(packPath, 'Race')).existsSync()) {
    Directory(path.join(packPath, 'Race')).deleteSync(recursive: true);
  }
  if (Directory(path.join(packPath, 'Demo')).existsSync()) {
    Directory(path.join(packPath, 'Demo')).deleteSync(recursive: true);
  }
  Directory(path.join(packPath, 'Demo')).createSync();
  Directory(path.join(packPath, 'Race')).createSync();
  if (!Directory(path.join(packPath, 'Race', 'Course')).existsSync()) {
    Directory(path.join(packPath, 'Race', 'Course')).createSync();
  }
  if (!Directory(path.join(packPath, 'Race', 'Common')).existsSync()) {
    Directory(path.join(packPath, 'Race', 'Common')).createSync();
  }
  if (!Directory(path.join(packPath, 'Race', 'Kart')).existsSync()) {
    Directory(path.join(packPath, 'Race', 'Kart')).createSync();
  }
  if (!Directory(path.join(packPath, 'rel')).existsSync()) {
    Directory(path.join(packPath, 'rel')).createSync();
  }
  if (!Directory(path.join(packPath, 'static')).existsSync()) {
    Directory(path.join(packPath, 'static')).createSync();
  }
  // if (!Directory(path.join(packPath, 'Scene')).existsSync()) {
  //   Directory(path.join(packPath, 'Scene')).createSync();
  // }
  if (Directory(path.join(packPath, 'Scene')).existsSync()) {
    Directory(path.join(packPath, 'Scene')).deleteSync(recursive: true);
  }
  Directory(path.join(packPath, 'Scene')).createSync();
  if (!Directory(path.join(packPath, 'Scene', 'UI')).existsSync()) {
    Directory(path.join(packPath, 'Scene', 'UI')).createSync();
  }
  if (!Directory(path.join(packPath, 'Scene', 'Model')).existsSync()) {
    Directory(path.join(packPath, 'Scene', 'Model')).createSync();
    Directory(path.join(packPath, 'Scene', 'Model', 'Kart')).createSync();
  }
  if (!Directory(path.join(packPath, 'sys')).existsSync()) {
    Directory(path.join(packPath, 'sys')).createSync();
  }
  if (!Directory(path.join(packPath, "..", "..", 'myCodes')).existsSync()) {
    copyGeckoAssetsToPack(packPath);
  }
  if (!Directory(path.join(packPath, 'codes')).existsSync()) {
    Directory(path.join(packPath, 'codes')).createSync();
    //updateGtcFiles(packPath);
  }
  for (var file in Directory(path.join(packPath, 'rel')).listSync()) {
    file.deleteSync(recursive: true);
  }
  for (var file in Directory(path.join(packPath, 'static')).listSync()) {
    file.deleteSync(recursive: true);
  }
  for (var file in Directory(path.join(packPath, 'sys')).listSync()) {
    file.deleteSync(recursive: true);
  }
  Directory(path.join(packPath, 'sys', 'P')).createSync();
  Directory(path.join(packPath, 'sys', 'E')).createSync();
  Directory(path.join(packPath, 'sys', 'J')).createSync();
  Directory(path.join(packPath, 'sys', 'K')).createSync();
  Directory(path.join(packPath, 'static', 'P')).createSync();
  Directory(path.join(packPath, 'static', 'E')).createSync();
  Directory(path.join(packPath, 'static', 'J')).createSync();
  Directory(path.join(packPath, 'static', 'K')).createSync();
}

String replaceCommonBmgTextWithVanillaNames(
    String contents, bool keepNintendo) {
  if (keepNintendo) {
    List<Cup> nintendoCups = getNintendoCups();
    int id = 6800;
    for (int i = 0; i < 8; i++) {
      int currentId = id + i;
      RegExp reg = RegExp('^[\\s\\t]*$currentId\\s*=.*\$', multiLine: true);

      contents = contents.replaceFirst(
          reg, '\n $currentId = ${nintendoCups[i].cupName}');
    }
    for (String key in vsMap.keys) {
      RegExp lastOccReg = RegExp(r'(?<!' + key + r'.*)' + key);
      if (contents.split('7043').length > 1) {
        contents =
            '${contents.split('7043')[0].replaceFirst(lastOccReg, vsMap[key]!)}7043${contents.split('7043')[1]}';
      } else {
        contents = contents.replaceFirst(lastOccReg, vsMap[key]!);
      }
    }
  }
  for (String key in battleMap.keys) {
    RegExp lastOccReg = RegExp(r'(?<!' + key + r'.*)' + key);

    if (contents.split('7043').length > 1) {
      contents =
          '${contents.split('7043')[0].replaceFirst(lastOccReg, battleMap[key]!)}7043${contents.split('7043')[1]}';
    } else {
      contents = contents.replaceFirst(lastOccReg, battleMap[key]!);
    }
  }
  List<String> wiimmId = ['703e', '703f', '7040', '7041'];
  List<String> wiimmStrings = [
    'All Tracks',
    'Original Tracks',
    'Custom Tracks',
    'New Tracks'
  ];
  for (int i = 0; i < wiimmId.length; i++) {
    RegExp reg = RegExp('^[\\s\\t]*${wiimmId[i]}\\s*=.*\$', multiLine: true);

    contents =
        contents.replaceFirst(reg, '\n ${wiimmId[i]} = ${wiimmStrings[i]}');
  }

  return contents;
}

/// Parses config.txt located in [packPath] and generates a list of all filenames without extension.
///
/// Note: config.txt file must be present.
List<String> getTracksFilenamesFromConfig(String packPath) {
  List<String> dirtyTrackFilenames = [];
  List<String> trackFilenames = [];
  File configFile = File(path.join(packPath, 'config.txt'));
  String contents = configFile.readAsStringSync();
  contents = contents.split(RegExp('N N.*WII'))[1];

  dirtyTrackFilenames = contents.split('\n');

  for (var dirty in dirtyTrackFilenames) {
    if (';'.allMatches(dirty).length == 5 &&
        !dirty.contains((r'0x02;')) &&
        !dirty.contains((r'0x03;'))) {
      //is track
      trackFilenames.add(dirty.split(';')[3].replaceAll(r'"', '').trimLeft());
    }
  }

  if (contents.contains('[SETUP-ARENA]')) {
    String arenaTxt = contents.split('[SETUP-ARENA]').last;

    List<Cup> arenaCups = parseArenaTxt(arenaTxt);
    for (Cup cup in arenaCups) {
      for (Track arena in cup.tracks) {
        if (arena.path != 'original file') {
          trackFilenames.add(arena.path);
        }
      }
    }
  }
  //print(trackFilenames);
  return trackFilenames;
}

/// Generates the tracks.bmg.txt file and returns its path.
/// Otherwise, throws an exception.
///
/// Note: config.txt must exist.
Future<String> createBMGList(String packPath) async {
  File trackFile = File(path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt'));
  if (await trackFile.exists()) {
    await trackFile.delete();
  }
  // try {
  await Process.run(
      'wctct',
      [
        'create',
        'bmg',
        '--le-code',
        '--long',
        path.join(packPath, 'config.txt'),
        '--dest',
        path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt')
      ],
      runInShell: true);
  return path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt');
}

/// Comparator function that sorts files in numerical order,
///
///  while taking into account the special cases of "0_r" and "0_l".
int compareAlphamagically(File a, File b) {
  if (int.tryParse(path.basenameWithoutExtension(a.path)) == null &&
      int.tryParse(path.basenameWithoutExtension(a.path)) == null) {
    return a.path.compareTo(b.path);
  }
  if (int.tryParse(path.basenameWithoutExtension(a.path)) == null &&
      num.tryParse(path.basenameWithoutExtension(b.path)) != null) {
    return -1;
  }
  if (int.tryParse(path.basenameWithoutExtension(a.path)) != null &&
      int.tryParse(path.basenameWithoutExtension(b.path)) == null) {
    return 1;
  }
  return int.parse(path.basenameWithoutExtension(a.path))
      .compareTo(int.parse(path.basenameWithoutExtension(b.path)));
}

/// Combines all the icons located in [iconDir] directory and generates a new image file called "merged.png" that contains all the icons merged into a single image.
Future<File> createBigImage(Directory iconDir, int nCups) async {
  List<ui.Image> imageList = [];
  List<File> iconFileList = iconDir.listSync().whereType<File>().toList();
  iconFileList.sort((a, b) => compareAlphamagically(a, b));
  for (File icon in iconFileList) {
    imageList.add(await ImagesMergeHelper.loadImageFromFile(icon));
    var decodedImage = await decodeImageFromList(icon.readAsBytesSync());
    if (decodedImage.width != 128 || decodedImage.height != 128) {
      throw CtdmException(
          "'Icons/${path.basename(icon.path)}' isn't 128x128.'", null, '2501');
    }
  }

  ui.Image image = await ImagesMergeHelper.margeImages(imageList,
      fit: true, direction: Axis.vertical, backgroundColor: Colors.transparent);

  final data = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final bytes = data!.buffer.asUint8List();

  File mergedFile = File(path.join(iconDir.path, 'merged.png'));
  mergedFile = await mergedFile.writeAsBytes(bytes, flush: true);

  return mergedFile;
}

class _PatchWindowState extends State<PatchWindow> {
  late List<String> missingTracks = [];
  PatchingStatus patchStatus = PatchingStatus.running;
  String progressText = 'creating folder';
  bool keepNintendo = false;
  bool hasWiimmCup = false;
  String dolphin = "";
  String game = "";
  late SharedPreferences prefs;
  bool pleaseWait = false;
  @override
  void initState() {
    // try {
    loadSettings();
    if (File(path.join(widget.packPath, 'config.txt')).existsSync()) {
      String contents =
          File(path.join(widget.packPath, 'config.txt')).readAsStringSync();
      keepNintendo = contents.contains(r'N$SWAP');
      hasWiimmCup = contents.contains(r'%WIIMM-CUP = 1');
    }
    patch(widget.packPath);

    super.initState();
  }

  void loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    dolphin = prefs.getString('dolphin')!;
    setState(() {});
    game = prefs.getString('game')!;
  }

  void patch(String packPath) async {
    patchStatus = PatchingStatus.running;

    final String originalDiscPath = getOriginalDiscPath(packPath);
    final String workspace = path.dirname(path.dirname(packPath));

    //if some track files from config.txt are missing-> abort.

    //2, add arenaList to trackList.
    //3 manually copy the arena tracks in Race/Course with the right id.
    List<String> trackList =
        getTracksFilenamesFromConfig(packPath).toSet().toList();
    setState(() {
      progressText = "checking for missing tracks";
      missingTracks =
          checkTracklistInFolder(trackList, path.join(workspace, 'myTracks'));
    });
    await Future.delayed(const Duration(seconds: 1));
    if (missingTracks.isNotEmpty) {
      patchStatus = PatchingStatus.aborted;
      setState(() {});
      return;
    }

    //create folders structure
    String configTxtContents =
        File(path.join(packPath, 'config.txt')).readAsStringSync();
    List<Cup> arenaCups = [];
    if (configTxtContents.contains('[SETUP-ARENA]')) {
      arenaCups = parseArenaTxt(configTxtContents.split('[SETUP-ARENA]').last);
    } else {
      arenaCups = getArenaCups();
    }
    createFolders(packPath);

    List<bool> customUI = loadUIconfig(packPath);
    //read and parse characters.txt
    if (!await File(path.join(packPath, 'characters.txt')).exists()) {
      await File(path.join(packPath, 'characters.txt')).create();
      String contents = "";
      for (var element in characters2D.entries.toList()) {
        contents += "${element.key};\n";
      }
      await File(path.join(packPath, 'characters.txt')).writeAsString(contents);
    }
    List<String> customTxtContent =
        await File(path.join(packPath, 'characters.txt')).readAsLines();

    bool enableCustomChar = getNumberOfCustomCharacters(
            File(path.join(packPath, 'characters.txt'))) >
        0;

    Directory iconDir = Directory(path.join(packPath, 'Icons'));
    int nCups = getNumberOfIconsFromConfig(packPath);
    setState(() {
      progressText = "setting up cup icons";
    });

    await createBigImage(iconDir, nCups);

    setState(() {
      progressText = "copying ui files";
    });
    for (int i = 0; i < customUI.length; i++) {
      File f;

      if (customUI[i] == false) {
        f = File(getFileFromIndex(packPath, i).path);
      } else {
        f = File(path.join(packPath, 'myUI',
            path.basename(getFileFromIndex(packPath, i).path)));
      }
      String destPath =
          path.join(packPath, 'Scene', 'UI', path.basename(f.path));
      await f.copy(destPath);
      //since we are here, we can patch the icons
      await Process.run(
          'wszst',
          [
            'patch',
            '--le-menu',
            //'--9laps',
            '--cup-icons',
            path.join(packPath, 'Icons', 'merged.png'),
            '--links',
            destPath,
            '--overwrite',
            '--dest',
            destPath
          ],
          runInShell: true);
    }

    setState(() {
      progressText = "copying tracks";
    });
    await Directory(path.join(packPath, 'Race', 'Course', 'tmp')).create();

    //copy vaninlla tracks in tmp
    final ogRaceDir =
        Directory(path.join(originalDiscPath, 'files', 'Race', 'Course'));
    final originalTracksSzs =
        await ogRaceDir.list().where((event) => event is File).toList();

    for (var originalRaceFile in originalTracksSzs) {
      await File(originalRaceFile.path).copy(path.join(packPath, 'Race',
          'Course', 'tmp', path.basename(originalRaceFile.path)));
    }

    //copy custom tracks in tmp
    List<File> szsFileList = Directory(path.join(workspace, 'myTracks'))
        .listSync(recursive: true)
        .whereType<File>()
        .toList();
    szsFileList.retainWhere((element) => element.path.endsWith('.szs'));
    szsFileList.retainWhere((element) =>
        trackList.contains(path.basenameWithoutExtension(element.path)));
    for (File szs in szsFileList) {
      await szs.copy(path.join(
          packPath, 'Race', 'Course', 'tmp', path.basename(szs.path)));
    }

    setState(() {
      progressText = "patching lecode binaries";
    });

    await Future.delayed(const Duration(seconds: 1));
    for (GameVersion gv in fileMap.keys) {
      //copy lecode-XXX.bin from assets
      String isoVersion = gv.name;
      String lecodePath = path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "lecode_build",
          "lecode-$isoVersion.bin");
      await File(lecodePath)
          .copy(path.join(packPath, 'rel', "lecode-$isoVersion.bin"));
      //patch lecode with the new tracks

      List<String> wlectArgs = [
        'patch',
        path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
        '--overwrite',
        '--dest',
        path.join(packPath, 'rel', "lecode-$isoVersion.bin"),
        '--le-define',
        path.join(packPath, 'config.txt'),
        '--lpar', //added
        path.join(packPath, 'lpar.txt'), //added
      ];

      if (isoVersion == "PAL") {
        wlectArgs.addAll([
          '--track-dir',
          path.join(packPath, 'Race', 'Course'),
          '--copy-tracks',
          path.join(packPath, 'Race', 'Course', 'tmp'),
        ]);
      }

      //  wlect patch lecode-PAL.bin -od lecode-PAL.bin --le-define config.txt --track-dir .
      ProcessResult p = await Process.run('wlect', wlectArgs, runInShell: true);

      if (p.exitCode != 0 || p.stderr.toString().contains('! wlect')) {
        logString(LogType.ERROR, "PATCH ERROR:\n${p.stderr}");
        if (p.stderr.toString().contains('lpar.txt')) {
          throw CtdmException(p.stderr, null, '2101');
        } else {
          throw CtdmException(p.stderr, null, '2001');
        }
      }
    }
    //ovveride arena tracks
    int i = 0;
    for (Cup cup in arenaCups) {
      int j = 0;
      for (Track arena in cup.tracks) {
        if (arena.path != 'original file') {
          await File(path.join(
                  path.join(workspace, 'myTracks'), "${arena.path}.szs"))
              .copy(path.join(packPath, 'Race', 'Course',
                  "${getIdFromArenaCupTrack(i, j)}.szs"));
          await File(path.join(
                  path.join(workspace, 'myTracks'), "${arena.path}.szs"))
              .copy(path.join(packPath, 'Race', 'Course',
                  "${getIdFromArenaCupTrack(i, j)}_d.szs"));
        }
        j++;
      }
      i++;
    }
    //move main.dol and patch it with gecko codes
    //create gecko codes (.gct files)
    setState(() {
      progressText = "creating gecko codes";
      updateGtcFiles(packPath, File(path.join(packPath, 'gecko.txt')));
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      progressText = "patching main.dol and StaticR.rel";
    });
    String regionContent = readRegionFile(packPath);
    bool isOnline = regionContent.split(";").last == "true";
    String regionId = regionContent.split(";").first;
    for (GameVersion gv in fileMap.keys) {
      String letter = getLetterFromGameVersion(gv);
      File dolFile = File(path.join(path.dirname(Platform.resolvedExecutable),
          "data", "flutter_assets", "assets", "dols", "$letter.dol"));
      if (await File(path.join(packPath, 'sys', letter, "main.dol")).exists()) {
        await File(path.join(packPath, 'sys', letter, "main.dol")).delete();
      }
      File staticFile = File(path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "statics",
          "$letter.rel"));
      if (await File(path.join(packPath, 'static', letter, "StaticR.rel"))
          .exists()) {
        await File(path.join(packPath, 'static', letter, "StaticR.rel"))
            .delete();
      }
      await dolFile.copy(path.join(packPath, 'sys', letter, "main.dol"));
      await staticFile
          .copy(path.join(packPath, 'static', letter, "StaticR.rel"));

      // // try {
      String regionContent = readRegionFile(packPath);
      if (regionContent != "" && isOnline) {
        await Process.run(
            'wstrt',
            [
              'patch',
              '--add-lecode',
              '--region',
              regionId,
              '--wiimmfi',
              path.join(packPath, 'sys', letter, "main.dol"),
              '--add-section',
              path.join(packPath, 'codes', fileMap[gv]),
              '--overwrite',
              '--dest',
              path.join(packPath, 'sys', letter, "main.dol"),
            ],
            runInShell: false);

        await Process.run(
            'wstrt',
            [
              'patch',
              '--region',
              regionContent.split(";").first,
              '--wiimmfi',
              path.join(packPath, 'static', letter, "StaticR.rel"),
              '--overwrite',
              '--dest',
              path.join(packPath, 'static', letter, "StaticR.rel"),
            ],
            runInShell: false);
      } else {
        // wstrt patch --add-lecode main.dol
        await Process.run(
            'wstrt',
            [
              'patch',
              '--add-lecode',
              path.join(packPath, 'sys', letter, "main.dol"),
              '--add-section',
              path.join(packPath, 'codes', fileMap[gv]),
              '--overwrite',
              '--dest',
              path.join(packPath, 'sys', letter, "main.dol"),
            ],
            runInShell: false);
      }
    }

    //copy music
    setState(() {
      progressText = widget.fastPatch != true
          ? "creating music files (it might take a while)"
          : "skipping music (FAST PATCHING)";
    });
    if (widget.fastPatch != true) {
      await copyMusic(workspace, packPath);
    } else {
      Directory musicDir = Directory(path.join(packPath, 'Music'));
      if (await musicDir.exists()) {
        await musicDir.delete(recursive: true);
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    if (enableCustomChar) {
      setState(() {
        progressText = "swapping characters icons";
      });

      await Future.delayed(const Duration(seconds: 1));
      //add icon64 e icon32 to the some Scenes
      List<SceneComplete> filesWith2dCharacters = [
        SceneComplete.award,
        SceneComplete.race,
        SceneComplete.menuSingle,
        SceneComplete.menuMulti,
      ];

      for (SceneComplete scene in filesWith2dCharacters) {
        String baseName =
            path.basename(getFileFromIndex(packPath, scene.index).path);
        Directory extractedSzs =
            Directory("${path.join(packPath, 'Scene', 'UI', baseName)}.d");
        await Process.run(
            'wszst',
            [
              'extract',
              path.join(packPath, 'Scene', 'UI', baseName),
              '--dest',
              extractedSzs.path
            ],
            runInShell: true);

        await patchSzsWithImages(
            packPath,
            Directory(
              extractedSzs.path,
            ),
            customTxtContent,
            scene.index);
      }
    }
    //edit the Common.bmg of some Scenes
    List<SceneComplete> filesWithCommonBmg = [
      SceneComplete.menuSingle_,
      SceneComplete.menuMulti_,
      SceneComplete.race_,
      SceneComplete.award_
    ];
    setState(() {
      progressText = "editing names in Common.bmg";
    });
    await Future.delayed(const Duration(seconds: 1));

    final File trackBmgTxt = File(await createBMGList(packPath));
    String trackBmgTxtContents = await trackBmgTxt.readAsString();
    trackBmgTxtContents =
        replaceCommonBmgTextWithVanillaNames(trackBmgTxtContents, keepNintendo);

    trackBmgTxtContents =
        replaceCustomArenaNames(trackBmgTxtContents, arenaCups);

    File customCharTxtFile = File(path.join(packPath, 'characters.txt'));
    String customFileTxtContents = await customCharTxtFile.exists()
        ? await customCharTxtFile.readAsString()
        : "";
    for (SceneComplete scene in filesWithCommonBmg) {
      String baseName =
          path.basename(getFileFromIndex(packPath, scene.index).path);

      Directory("${path.join(packPath, 'Scene', 'UI', baseName)}.d");
      File sceneSzs = File(path.join(packPath, 'Scene', 'UI',
          path.basename(getFileFromIndex(packPath, scene.index).path)));
      File commonTxtFile = await extractSzsAndDecode(
          packPath,
          Directory((path.join(packPath, 'Scene', 'UI'))),
          path.basename(sceneSzs.path));

      String commonTxtContents = await commonTxtFile.readAsString();
      commonTxtContents = replaceCharacterNameInCommonTxt(
          packPath, commonTxtContents, customFileTxtContents);

      String completeBmgContents = commonTxtContents + trackBmgTxtContents;
      completeBmgContents = replaceCharacterNameInCommonTxt(
          packPath, completeBmgContents, customFileTxtContents);
      completeBmgContents = replaceCommonBmgTextWithVanillaNames(
          completeBmgContents, keepNintendo);

      commonTxtFile.writeAsString(completeBmgContents);
      await encodeAndClose(commonTxtFile, sceneSzs);
    }
    List<String> allKartsList = [];
    // List<String> driverBrresList = [];
    // List<String> awardBrresList = [];
    if (enableCustomChar) {
      setState(() {
        progressText = "swapping character models";
      });
      await Future.delayed(const Duration(seconds: 1));
      await File(path.join(originalDiscPath, 'files', 'Demo', 'Award.szs'))
          .copy(path.join(packPath, 'Demo', 'Award.szs'));
      await File(path.join(
              originalDiscPath, 'files', 'Scene', 'Model', 'Driver.szs'))
          .copy(path.join(packPath, 'Scene', 'Model', 'Driver.szs'));

      await Process.run(
          'wszst',
          [
            'extract',
            path.join(packPath, 'Demo', 'Award.szs'),
            '--dest',
            "${path.join(packPath, 'Demo', 'Award.szs')}.d",
          ],
          runInShell: true);

      await Process.run(
          'wszst',
          [
            'extract',
            path.join(packPath, 'Scene', 'Model', 'Driver.szs'),
            '--dest',
            "${path.join(packPath, 'Scene', 'Model', 'Driver.szs')}.d",
          ],
          runInShell: true);

      List<String> customStrings = customTxtContent
          .where((element) => element.split(';')[1].trim().isNotEmpty)
          .toList();
      List<String> charNames = [];
      if (enableCustomChar) {
        setState(() {
          progressText = "swapping vehicles files\nIt might take some time...";
        });

        //extract /Scene/Model/Driver.szs
        for (String string in customStrings) {
          String name = string.split(';')[0];
          bool characterIsExtraPain =
              ['Daisy', 'Peach', 'Rosalina'].contains(name);
          charNames.add(name);
          String customChar = string.split(';')[1];
          String pathOfCustomDir =
              getPathOfCustomCharacter(packPath, customChar);
          //sposta il file in Scene/Model/allkart.
          List<FileSystemEntity> allKarts = await Directory(pathOfCustomDir)
              .list()
              .where((files) => files.path.contains('allkart.szs'))
              .toList();
          List<FileSystemEntity> allKartsBT = await Directory(pathOfCustomDir)
              .list()
              .where((files) => files.path.contains('allkart_BT.szs'))
              .toList();
          List<File> drivers = (await Directory(pathOfCustomDir)
                  .list()
                  .where((files) => files.path.contains('driver.brres'))
                  .toList())
              .whereType<File>()
              .toList();
          List<File> awards = (await Directory(pathOfCustomDir)
                  .list()
                  .where((files) =>
                      files.path.contains(RegExp(r'award[1-3]*\.brres')))
                  .toList())
              .whereType<File>()
              .toList();

          if (drivers.isNotEmpty) {
            String suffix = "";
            if (characterIsExtraPain) {
              suffix = "_menu";
            }
            String driverFileName = "${characters3D[name]}$suffix.brres";
            //driverBrresList.add("${characters3D[name]}.brres");
            await drivers[0].copy(path.join(
                packPath, 'Scene', 'Model', 'Driver.szs.d', driverFileName));
          } else {
            // // logString(LogType.ERROR,
            //     '$pathOfCustomDir does not contain driver.brres. skipping.');
          }

          if (awards.isNotEmpty) {
            //awardBrresList.add("${characters3D[name]}.brres");
            await awards[0].copy(path.join(packPath, 'Demo', 'Award.szs.d',
                "${characters3D[name]}.brres"));
          } else {
            // logString(LogType.ERROR,
            //     '$pathOfCustomDir does not contain award.brres. skipping.');
          }
          if (characterIsExtraPain) {
            if (awards.length == 2) {
              await awards[1].copy(path.join(packPath, 'Demo', 'Award.szs.d',
                  "${characters3D[name]}3.brres"));
            } else {
              await awards[0].copy(path.join(packPath, 'Demo', 'Award.szs.d',
                  "${characters3D[name]}3.brres"));
            }
          }

          if (allKarts.isNotEmpty) {
            await File(allKarts[0].path).copy(path.join(packPath, 'Scene',
                'Model', 'Kart', "${characters3D[name]}-allkart.szs"));
            allKartsList.add("${characters3D[name]}-allkart.szs");
          } else {
            // logString(LogType.ERROR,
            //     '$pathOfCustomDir does not contain allkart.szs. skipping.');
          }

          if (allKartsBT.isNotEmpty) {
            await File(allKartsBT[0].path).copy(path.join(packPath, 'Scene',
                'Model', 'Kart', "${characters3D[name]}-allkart_BT.szs"));
            allKartsList.add("${characters3D[name]}-allkart_BT.szs");
          } else {
            // logString(LogType.ERROR,
            //     '$pathOfCustomDir does not contain allkart_BT.szs. skipping.');
          }

          //spostare i vari kart in /Race/Kart
          if (await Directory(path.join(pathOfCustomDir, 'karts')).exists()) {
            List<File> vehiclesFilesInKartsFolder =
                (await Directory(path.join(pathOfCustomDir, 'karts'))
                        .list()
                        .toList())
                    .whereType<File>()
                    .toList();

            for (File file in vehiclesFilesInKartsFolder) {
              if (!file.path.endsWith(".szs")) continue;
              String cleanFileName = path.basename(file.path);
              String suffix = file.path.endsWith("_4.szs") ? "_4.szs" : ".szs";
              for (String extraName in characters3D.values) {
                cleanFileName =
                    cleanFileName.replaceFirst(RegExp("-$extraName.*"), '');
              }

              await file.copy(path.join(packPath, 'Race', 'Kart',
                  "$cleanFileName-${characters3D[name]}$suffix"));
            }
          } else {
            logString(LogType.ERROR,
                '$pathOfCustomDir does not contain karts folder. skipping.');
          }
          await Process.run(
              'wszst',
              [
                'create',
                path.join(packPath, 'Demo', 'Award.szs.d'),
                '--overwrite',
                '--dest',
                path.join(packPath, 'Demo', 'Award.szs'),
              ],
              runInShell: true);
          await Process.run(
              'wszst',
              [
                'create',
                path.join(packPath, 'Scene', 'Model', 'Driver.szs.d'),
                '--overwrite',
                '--dest',
                path.join(packPath, 'Scene', 'Model', 'Driver.szs'),
              ],
              runInShell: true);
        }
      }
    }

    setState(() {
      progressText = "deleting tmp files";
    });
    await Future.delayed(const Duration(seconds: 1));

    Directory(path.join(packPath, 'Scene', 'UI'))
        .listSync()
        .where((element) => !element.path.endsWith('.szs'))
        .toList()
        .forEach((element) async {
      await element.delete(recursive: true);
    });
    if (Directory(path.join(packPath, 'Demo', 'Award.szs.d')).existsSync()) {
      await Directory(path.join(packPath, 'Demo', 'Award.szs.d'))
          .delete(recursive: true);
    }
    if (Directory(path.join(packPath, 'Scene', 'Model', 'Driver.szs.d'))
        .existsSync()) {
      await Directory(path.join(packPath, 'Scene', 'Model', 'Driver.szs.d'))
          .delete(recursive: true);
    }
    await Directory(path.join(packPath, 'Race', 'Course', 'tmp'))
        .delete(recursive: true);

    List<Gecko> geckoList =
        parseGeckoTxt(packPath, File(path.join(packPath, 'gecko.txt')));
    var (_, packId) = getPackNameAndId(packPath);
    setState(() {
      progressText = "editing xml file";

      completeXmlFile(
          packId,
          packPath,
          isOnline,
          regionId,
          customUI,
          Directory(path.join(packPath, 'Scene', 'UI'))
              .listSync()
              .whereType<File>()
              .toList(),
          allKartsList,
          geckoList,
          readMiscTxt(
              getListOfMisc(), File(path.join(widget.packPath, 'misc.txt'))));
    });
    File jsonFile = File(
        path.join(packPath, "${path.basenameWithoutExtension(packPath)}.json"));
    String packJsonContents = await jsonFile.readAsString();

    packJsonContents = clearPatchesJson(packJsonContents);

    for (Gecko gecko in geckoList.where((element) => element.canBeToggled)) {
      packJsonContents = addPatchJson(gecko.name, packId, packJsonContents);
    }
    packJsonContents = addPatchJson('My Stuff', packId, packJsonContents);
    await jsonFile.writeAsString(const JsonEncoder.withIndent(' ')
        .convert(json.decode(packJsonContents)));
    await File(path.join(packPath, 'Icons', 'merged.png')).delete();

    setState(() {
      patchStatus = PatchingStatus.completed;
      logString(LogType.INFO, "patch completed");
    });
  }

  ///Reads music.txt and copies both music files in mDir from myMusic/mDir to Pack/Music
  Future<void> copyMusic(workspace, packPath) async {
    if (Platform.isLinux) {
      await giveExecPermissionToBrstmConverter();
    }
    File musicTxt = File(path.join(packPath, "music.txt"));
    Directory musicDir = Directory(path.join(packPath, 'Music'));
    if (await musicDir.exists()) {
      await musicDir.delete(recursive: true);
    }
    await musicDir.create();
    Directory tmpDir = Directory(path.join(packPath, 'Music', 'tmp'));
    if (!await tmpDir.exists()) {
      await tmpDir.create();
    }

    if (!await musicTxt.exists()) return;
    List<String> tracksIdHex = [];

    for (String line in await musicTxt.readAsLines()) {
      String id = line.substring(0, 3);
      tracksIdHex.add(id); //get id of track and add it

      String filepath = line.substring(4);

      //deprecated
      if (!filepath.endsWith("brstm") && Platform.isMacOS) {
        return;
      }
      if (filepath.endsWith(".brstm")) {
        //if brstm file pair

        try {
          File normalFile = Directory(path.join(
                  path.join(workspace, 'myMusic', path.dirname(filepath))))
              .listSync()
              .whereType<File>()
              .firstWhere((element) =>
                  !isFastBrstm(element.path) &&
                  element.path.contains(path
                      .basename(filepath)
                      .replaceFirst(RegExp(r'_+[a-zA-Z]?\.brstm$'), '')));
          await normalFile.copy(path.join(musicDir.path, '$id.brstm'));
        } on StateError catch (stateError) {
          logString(LogType.ERROR,
              "myMusic/${path.dirname(filepath)} is missing the normal.brstm file.");

          throw CtdmException(
              "myMusic/${path.dirname(filepath)} is missing the normal .brstm file.",
              stateError.stackTrace,
              '5501');
        }
        try {
          File fastFile = Directory(path.join(
                  path.join(workspace, 'myMusic', path.dirname(filepath))))
              .listSync()
              .whereType<File>()
              .firstWhere((element) => isFastBrstm(element.path));

          await fastFile.copy(path.join(musicDir.path, '${id}_f.brstm'));
        } on StateError catch (stateError) {
          logString(LogType.ERROR,
              "myMusic/${path.dirname(filepath)} is missing the fast .brstm file.");
          throw CtdmException(
              "myMusic/${path.dirname(filepath)} is missing the fast .brstm file.",
              stateError.stackTrace,
              '5502');
        }
      } else {
        //deprecated
        await fileToBrstm(
            path.join(workspace, "myMusic", filepath),
            path.join(packPath, "Music", "tmp"),
            path.join(packPath, "Music"),
            id);
      }
    }
    await tmpDir.delete(recursive: true);
  }

  void setWait(bool value) {
    setState(() {
      pleaseWait = value;
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: patchStatus == PatchingStatus.running
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Column(
            children: [
              //STATE RUNNING
              if (patchStatus == PatchingStatus.running)
                Column(
                  children: [
                    Text(
                      "Patching...",
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headlineLarge?.fontSize,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.amberAccent,
                        size: 50,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        progressText,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontSize,
                        ),
                      ),
                    ),
                  ],
                )
              else if (patchStatus == PatchingStatus.completed)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Patch is completed",
                        style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.fontSize,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                            child: FractionallySizedBox(
                          widthFactor: 0.65,
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AfterPatchOptions(
                                  Icons.folder_zip,
                                  "Create a\n zip file",
                                  'Zip file created',
                                  zipPack,
                                  [widget.packPath],
                                  updateWaiting: setWait,
                                ),
                                AfterPatchOptions(
                                    Icons.play_circle_outline,
                                    "Run on \nDolphin",
                                    'Execution stopped',
                                    runOnDolphin, [
                                  dolphin,
                                  path.join(widget.packPath,
                                      "${path.basename(widget.packPath)}.json"),
                                  widget.packPath,
                                  game
                                ]),
                              ],
                            ),
                          ),
                        ))),
                    Visibility(
                      visible: pleaseWait,
                      child: const Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: Column(
                            children: [
                              Text(
                                "Please wait.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white54),
                              ),
                              Text(
                                "Do not exit this page.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          )),
                    ),
                  ],
                )
              else
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
                                    .headlineMedium
                                    ?.fontSize),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "the following tracks were not found in myTracks folder:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.fontSize),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              height: 300,
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
                                          )),
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
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Text(
                                  "the patching process has been stopped.",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.fontSize),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                )
              // Resto del codice...
            ],
          ),

          // Resto del codice...
        ],
      ),
    );
  }
}

//replace Vanilla Names with Custom names in Common.bmg from config.txt
String replaceCustomArenaNames(
    String trackBmgTxtContents, List<Cup> arenaCups) {
  int i = 0;

  for (Cup cup in arenaCups) {
    int j = 0;
    for (Track track in cup.tracks) {
      String arenaId = getIdFromArenaCupTrack(i, j);

      trackBmgTxtContents =
          replaceTrackName(trackBmgTxtContents, "7$arenaId", track.name);
      j++;
    }
    i++;
  }

  return trackBmgTxtContents;
}

Future<File> extractSzsAndDecode(
    String packPath, Directory parentDir, String basename) async {
  String dirPath = path.join(parentDir.path, "$basename.d");
  await Process.run(
      'wszst', ['extract', path.join(parentDir.path, basename), '-D', dirPath],
      runInShell: true);

  await Process.run(
      'wbmgt',
      [
        'decode',
        path.join(dirPath, 'message', 'Common.bmg'),
        '--dest',
        path.join(dirPath, 'message', 'Common.txt'),
      ],
      runInShell: true);
  return File(path.join(dirPath, 'message', 'Common.txt'));
}

Future<void> encodeAndClose(File commonTxt, File f) async {
  await Process.run(
      'wbmgt',
      [
        'encode',
        commonTxt.path,
        '--overwrite',
        '--dest',
        path.join(path.dirname(commonTxt.path), 'Common.bmg')
      ],
      runInShell: true);

  await Process.run(
      'wszst',
      [
        'create',
        path.join(path.dirname(f.path), "${path.basename(f.path)}.d"),
        '--overwrite',
        '--dest',
        f.path,
      ],
      runInShell: true);
}

// ignore: must_be_immutable
class AfterPatchOptions extends StatelessWidget {
  IconData icon;
  String text;
  Function customFunction;
  List<String> parameters;
  String modalTitle;
  String tmpString = "";
  Function? updateWaiting;
  AfterPatchOptions(this.icon, this.text, this.modalTitle, this.customFunction,
      this.parameters,
      {this.updateWaiting, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 140,
      child: Column(
        children: [
          IconButton(
            splashRadius: 50,
            iconSize: 80,
            color: Colors.amberAccent,
            onPressed: () async => {
              if (updateWaiting != null) {updateWaiting!(true)},
              tmpString = await customFunction(parameters),
              if (tmpString.isNotEmpty)
                {
                  if (updateWaiting != null) {updateWaiting!(false)},
                  _showResultModal(context, tmpString)
                }
            },
            icon: Icon(
              icon,
              //size: 80,
              //color: Colors.amberAccent,
            ),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showResultModal(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            modalTitle,
            style: const TextStyle(color: Colors.amberAccent),
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
}

String replaceTrackName(
    String trackBmgTxtContents, String arenaId, String trackName) {
  List<String> lines = trackBmgTxtContents.split('\n');

  RegExp r = RegExp(r'^\s*' + arenaId + r'.*=');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith(r)) {
      lines[i] = ' $arenaId = $trackName';

      break;
    }
  }

  String modifiedContents = lines.join('\n');
  return modifiedContents;
}
