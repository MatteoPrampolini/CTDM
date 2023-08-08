import 'dart:io';
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
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merge_images/merge_images.dart';
import 'package:path/path.dart' as path;

import 'drawer_options/custom_ui.dart';

class PatchWindow extends StatefulWidget {
  final String packPath;
  final bool? fastPatch;
  const PatchWindow(this.packPath, {super.key, this.fastPatch});

  @override
  State<PatchWindow> createState() => _PatchWindowState();
}

enum PatchingStatus { aborted, running, completed }

void completeXmlFile(String packPath, bool isOnline, String regionId,
    List<bool> customUI, List<File> sceneFiles, List<String> allKartsList) {
  String packName = path.basename(packPath);
  File xmlFile = File(path.join(packPath, "$packName.xml"));
  String contents = xmlFile.readAsStringSync();
  //1 common <folder external="/PACKNAME/Race/Common/xxx" disc="/Race/Common/xxx/" create=true/>
  Directory commonDir = Directory(path.join(packPath, 'Race', 'Common'));
  String commonBigString = "";
  List<Directory> commonDirList =
      commonDir.listSync().whereType<Directory>().toList();
  for (Directory common in commonDirList) {
    commonBigString +=
        '<folder external="/$packName/Race/Common/${path.basename(common.path)}" disc="/Race/Common/${path.basename(common.path)}/" create="true"/>\n\t\t';
  }
  //2 course dir
  // Directory courseDir = Directory(path.join(packPath, 'Race', 'Course'));
  // String courseBigString = "";
  // List<File> courseDirList = courseDir.listSync().whereType<File>().toList();
  // for (File course in courseDirList) {
  //   courseBigString +=
  //       '<file external="/$packName/Race/Course/${path.basename(course.path)}" disc="/Race/Course/${path.basename(course.path)}" create="true"/>\n\t\t';
  // }
  // //3 music dir
  // Directory musicDir = Directory(path.join(packPath, 'Music'));
  // String musicBigString = "";
  // List<File> musicDirList = musicDir.listSync().whereType<File>().toList();
  // for (File music in musicDirList) {
  //   int hex = int.parse(path.basename(music.path).substring(0, 3), radix: 16);
  //   if (hex < 32) {
  //     musicBigString +=
  //         '<file external="/$packName/Music/${path.basename(music.path)}" disc="/sound/strm/${path.basename(music.path)}"/>\n\t\t';
  //   } else {
  //     musicBigString +=
  //         '<file external="/$packName/Music/${path.basename(music.path)}" disc="/sound/strm/${path.basename(music.path)}" create="true"/>\n\t\t';
  //   }
  // }
  String onlinePart =
      isOnline ? '<memory offset="0x800017C4" value="$regionId"/>' : '';

  String customUi = createXmlStringForUi(packPath, customUI, sceneFiles);
  String customChar = xmlReplaceCharactersModelScenes(packPath, allKartsList);
  contents = contents.replaceFirst(
      RegExp(r'<!--MY COMMONS-->.*<!--END MY TRACKS-->', dotAll: true),
      '<!--MY COMMONS-->\n\t\t$commonBigString$onlinePart\n$customUi$customChar<!--END MY TRACKS-->\t\t');

  //print(contents);
  //print(commonBigString);
  //print(courseBigString);
  xmlFile.writeAsStringSync(contents, mode: FileMode.write);
}

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
  //contents = contents.split(RegExp(r'6800.= '))[1];
  //List<String> lines = contents.split('\n');
  //print(tracksDirty);
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
    if (';'.allMatches(dirty).length == 5 && !dirty.contains((r'0x02;'))) {
      //is track
      trackFilenames.add(dirty.split(';')[3].replaceAll(r'"', '').trimLeft());
    }
  }
  //print(trackFilenames);
  return trackFilenames;
}

/// Parses tracks.bmg.txt located in [packPath] and generates a list of all display names.
///
/// Note: tracks.bmg.txt file must be present.
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
  //return parseBMGList(packPath);
  // } on Exception catch (_) {
  //   logString(LogType.ERROR, _.toString());
  //   rethrow;
  // }
  // String contents = trackFile.readAsStringSync();
  // int begin = contents.lastIndexOf(RegExp(r'703e'));
  // int end = contents.lastIndexOf(RegExp(r'7041'));
  // contents = contents.replaceRange(begin, end,
  //     "703e\t= All tracks\n703f\t= Original tracks\n7040\t= Custom tracks\n703e\t= New Tracks\n");
  // //contents.split(RegExp(r'703e.= '))[1].repl
  // contents = contents.replaceFirstMapped(
  //     'beginner_course', (match) => 'Luigi Circuit');
  //trackFile.writeAsStringSync(contents, mode: FileMode.write);
}

///Wrapper function. This function calls multiple functions.
///
///At the end of the execution MenuSingle_U.szs will be patched with the new bmgs.

///Returns the display name for a given filename from the config.txt
String getBmgFromFileName(File configFile, String filePath) {
  String contents = configFile.readAsStringSync();
  int begin = contents.indexOf(path.basenameWithoutExtension(filePath));
  contents = contents.replaceRange(0, begin, '');
  return contents.split(";")[1].replaceAll('"', '').trim();
}

///Returns list of IDs [ex:700a] from bmg.txt's content
List<String> getIdFromTracksBmgTxt(List<String> bmgContent, String trackName) {
  List<String> ids = [];
  for (var line in bmgContent) {
    if (line.contains(trackName)) {
      ids.add(line.trim().replaceRange(0, 1, '').replaceRange(3, null, ''));
    }
  }
  return ids;
}

///Check if in [configTrackList] some tracks need a common folder. if so, create it.
Future<void> trackPathToCommon(
    String workspace, String packPath, List<String> configTrackList) async {
  File configFile = File(path.join(packPath, 'config.txt'));

  //tracksWithCommon has size==2
  List tracksWithCommon = getTracksDirWithCommons(
      path.join(workspace, 'myTracks'), configTrackList);
  List<String> lines =
      File(path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt'))
          .readAsLinesSync();

  int i = 0;
  //for each track basename with commons
  for (var trackBasename in tracksWithCommon[0]) {
    List<String> ids = getIdFromTracksBmgTxt(
        lines, getBmgFromFileName(configFile, trackBasename));
    for (String id in ids) {
      //(the same display name can have multiple ids)
      createSingleCommon(packPath, id, tracksWithCommon[1][i]);
    }
    i++;
  }
}

///Creates common folder for specific track id in Race/Common/
void createSingleCommon(String packPath, String id, String srcFolderPath) {
  Directory(path.join(packPath, 'Race', 'Common', id)).createSync();

  Directory srcFolder = Directory(srcFolderPath);
  srcFolder.listSync().whereType<File>().forEach((file) {
    if (file.path.endsWith('.bin')) {
      file.copySync(
          path.join(packPath, 'Race', 'Common', id, path.basename(file.path)));
    }
  });
}

///Patches MenuSingle.szs by modifying its icons.
///
///Note: Do not confuse MenuSingle.szs with MenuSingle_U.szs.
Future<void> patchIcons(String workspace, String packPath, bool customUI,
    List<String> charactersTxtContent) async {
  File origSingle = getFileFromIndex(packPath, SceneComplete.menuSingle.index);

  origSingle.copySync(path.join(packPath, 'Scene', 'UI', 'MenuSingle.szs'));

  Directory iconDir = Directory(path.join(packPath, 'Icons'));
  int nCups = getNumberOfIconsFromConfig(packPath);
  if (iconDir.listSync().whereType<File>().length < nCups + 2) {
    logString(LogType.ERROR, "not enough icons to patch");
    return;
  }
  //wszst patch MenuSingle.szs --le-menu --cup-icons ./icons.tpl --links
  // try {
  await createBigImage(iconDir, nCups);

  await Process.run(
      'wszst',
      [
        'extract',
        path.join(packPath, 'Scene', 'UI', 'MenuSingle.szs'),
        '-D',
        path.join(packPath, 'Scene', 'UI', 'MenuSingle.szs.d')
      ],
      runInShell: true);
  await patchSzsWithImages(
      packPath,
      Directory(path.join(packPath, 'Scene', 'UI', 'MenuSingle.szs.d')),
      charactersTxtContent,
      SceneComplete.menuSingle.index);
  // } on Exception catch (_) {
  //   logString(LogType.ERROR, _.toString());
  //   rethrow;
  // }
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
  @override
  void initState() {
    // try {
    if (File(path.join(widget.packPath, 'config.txt')).existsSync()) {
      String contents =
          File(path.join(widget.packPath, 'config.txt')).readAsStringSync();
      keepNintendo = contents.contains(r'N$SWAP');
      hasWiimmCup = contents.contains(r'%WIIMM-CUP = 1');
    }
    patch(widget.packPath);
    // } on Exception catch (_) {
    //   logString(LogType.ERROR, _.toString());
    //   rethrow;
    // }
    super.initState();
  }

  Future<void> editMenuSingle(String workspace, String packPath,
      List<bool> customUI, String customTxtContent) async {
    //copy MenuSingle_U.szs

    File origMenuFile;
    if (customUI[SceneComplete.menuSingle_.index] == true) {
      origMenuFile = File(path.join(packPath, 'myUI', 'MenuSingle_U.szs'));
    } else {
      origMenuFile =
          getFileFromIndex(packPath, SceneComplete.menuSingle_.index);
    }
    await origMenuFile
        .copy(path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.szs'));
    //create tracks.bmg.txt
    final File trackBmgTxt = File(await createBMGList(packPath));

    //print(newContents);

    // try {
    //  wbmgt decode MenuSingle_U.szs --dest MenuSingle_U.txt
    await Process.run(
        'wbmgt',
        [
          'decode',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.txt'),
        ],
        runInShell: true);
    //MenuSingle_U.szs (file) extract  -> MenuSingle_U.d (folder)
    File menuSingleTxt =
        File(path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.txt'));

    await menuSingleTxt.writeAsString(replaceCharacterNameInCommonTxt(
        packPath, menuSingleTxt.readAsStringSync(), customTxtContent));

    await Process.run(
        'wszst',
        [
          'extract',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.d'),
        ],
        runInShell: true);
    //edit MenuSingle_U.txt with tracks.bmg.txt content
    String contents = await trackBmgTxt.readAsString();

    contents = replaceCommonBmgTextWithVanillaNames(contents, keepNintendo);

    contents = contents.replaceAll(RegExp(r'#BMG'), '');

    File editedMenuFile =
        File(path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.txt'));
    await editedMenuFile.writeAsString(contents, mode: FileMode.append);
    //MenuSingle_U.txt -> Common.bmg (MenuSingle_U.d/Common.bmg)
    //  wbmgt encode MenuSingle_U.txt

    await Process.run(
        'wbmgt',
        [
          'encode',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.txt'),
          '--overwrite',
          '--dest',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.d', 'message',
              'Common.bmg'),
        ],
        runInShell: true);
    //MenuSingle_U.szs (file) <- compact MenuSingle_U.d (folder)
    await Process.run(
        'wszst',
        [
          'create',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.d'),
          '--overwrite',
          '--dest',
          path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.szs'),
        ],
        runInShell: true);

    // } on Exception catch (_) {
    //   logString(LogType.ERROR, _.toString());
    //   rethrow;
    // }
  }

  void patch(String packPath) async {
    final String originalDiscPath = getOriginalDiscPath(packPath);
    patchStatus = PatchingStatus.running;
    //create folders
    createFolders(packPath);
    List<bool> customUI = loadUIconfig(packPath);
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
    String workspace = path.dirname(path.dirname(packPath));
    //create gecko codes
    setState(() {
      progressText = "creating gecko codes";
      updateGtcFiles(packPath, File(path.join(packPath, 'gecko.txt')));
    });
    await Future.delayed(const Duration(seconds: 1));
    //get list of track files
    List<String> trackList =
        getTracksFilenamesFromConfig(packPath).toSet().toList();
    //check missing tracks
    setState(() {
      progressText = "checking for missing tracks";
      missingTracks =
          checkTracklistInFolder(trackList, path.join(workspace, 'myTracks'));
    });
    await Future.delayed(const Duration(seconds: 1));
    //if there are missing tracks, abort the patch.
    if (missingTracks.isNotEmpty) {
      patchStatus = PatchingStatus.aborted;
      return;
    }
    setState(() {
      progressText = "patching icons";
    });

    //await Future.delayed(Duration(seconds: 1));
    // patch MenuSingle.szs with icons.
    await patchIcons(workspace, packPath,
        customUI[SceneComplete.menuSingle.index], customTxtContent);
    setState(() {
      progressText = "patching singleplayer menu";
    });

    //patch MenuSingle_U.szs with the new bmgs.
    await editMenuSingle(workspace, packPath, customUI,
        await File(path.join(packPath, 'characters.txt')).readAsString());

    //create Common/xxx folders
    await trackPathToCommon(workspace, packPath, trackList);

    //create list of szs files. the files will be copied into Race/Course/tmp
    List<File> szsFileList = Directory(path.join(workspace, 'myTracks'))
        .listSync(recursive: true)
        .whereType<File>()
        .toList();
    szsFileList.retainWhere((element) => element.path.endsWith('.szs'));
    szsFileList.retainWhere((element) =>
        trackList.contains(path.basenameWithoutExtension(element.path)));

    //For each versions
    setState(() {
      progressText = "copying tracks";
    });
    for (GameVersion gv in fileMap.keys) {
      //copy tracks to tmp
      await Directory(path.join(packPath, 'Race', 'Course', 'tmp')).create();
      for (File szs in szsFileList) {
        await szs.copy(path.join(
            packPath, 'Race', 'Course', 'tmp', path.basename(szs.path)));
      }
      // List<String> preAwardsRaces = [
      //   'winningrun_demo.szs',
      //   'loser_demo.szs',
      //   'draw_demo.szs',
      //   'ending_demo.szs'
      // ];
      // for (String awardRace in preAwardsRaces) {
      //   await File(path.join(
      //           originalDiscPath, 'files', 'Race', 'Course', awardRace))
      //       .copy(path.join(packPath, 'Race', 'Course', 'tmp', awardRace));
      // }
      final ogRaceDir = Directory(
          path.join(getOriginalDiscPath(packPath), 'files', 'Race', 'Course'));
      final originalTracksSzs =
          await ogRaceDir.list().where((event) => event is File).toList();

      for (var originalRaceFile in originalTracksSzs) {
        await File(originalRaceFile.path).copy(path.join(packPath, 'Race',
            'Course', 'tmp', path.basename(originalRaceFile.path)));
      }

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
      // // try {
      //  wlect patch lecode-PAL.bin -od lecode-PAL.bin --le-define config.txt --track-dir .
      await Process.run(
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
            '--copy-tracks',
            path.join(packPath, 'Race', 'Course', 'tmp'),
            '--lpar', //added
            path.join(packPath, 'lpar.txt'), //added
          ],
          runInShell: false);
      // final _ = await process.exitCode;
      //stdout.addStream(process.stdout);
      //stderr.addStream(process.stderr);
      // } on Exception catch (_) {
      //   logString(LogType.ERROR, _.toString());
      //   rethrow;
      //   //print(_);
      // }
      //needed?
      await Directory(path.join(packPath, 'Race', 'Course', 'tmp'))
          .delete(recursive: true);
    }

    //move main.dol and patch it with gecko codes
    setState(() {
      progressText = "patching main.dol";
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
      // } on Exception catch (_) {
      //   //print(_);
      //   logString(LogType.ERROR, _.toString());
      //   rethrow;
      // }
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

    setState(() {
      progressText = "copying ui files";
    });
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

    //it doesn't matter if raceU gets overwritten in the next for
    File raceU = getFileFromIndex(packPath, SceneComplete.race_.index);
    await raceU
        .copy(path.join(packPath, 'Scene', 'UI', path.basename(raceU.path)));

    List<SceneComplete> neededFiles = [SceneComplete.award, SceneComplete.race];
    if (enableCustomChar) {
      for (SceneComplete scene in neededFiles) {
        File f = getFileFromIndex(packPath, scene.index);
        await f.copy(path.join(packPath, 'Scene', 'UI', path.basename(f.path)));
      }
    }
    for (int i = 0; i < customUI.length; i++) {
      if (customUI[i] == false ||
          i == SceneComplete.menuSingle.index ||
          i == SceneComplete.menuSingle_.index) {
        continue;
      }
      File f = File(path.join(
          packPath, 'myUI', path.basename(getFileFromIndex(packPath, i).path)));

      await f.copy(path.join(packPath, 'Scene', 'UI', path.basename(f.path)));
    }

    await Process.run(
        'wszst',
        [
          'extract',
          path.join(packPath, 'Scene', 'UI', 'Race_U.szs'),
          '--dest',
          "${path.join(packPath, 'Scene', 'UI', 'Race_U.szs')}.d",
        ],
        runInShell: true);
    await Process.run(
        'wbmgt',
        [
          'decode',
          path.join(
              packPath, 'Scene', 'UI', 'Race_U.szs.d', 'message', 'Common.bmg'),
          '--dest',
          path.join(
              packPath, 'Scene', 'UI', 'Race_U.szs.d', 'message', 'Common.txt'),
        ],
        runInShell: true);

    File raceUcommon = File(path.join(
        packPath, 'Scene', 'UI', 'Race_U.szs.d', 'message', 'Common.txt'));
    String raceUcontentsTxt = await raceUcommon.readAsString();
    raceUcontentsTxt =
        replaceCommonBmgTextWithVanillaNames(raceUcontentsTxt, keepNintendo);

    await raceUcommon.writeAsString(replaceCharacterNameInCommonTxt(
        packPath,
        raceUcontentsTxt,
        await File(path.join(packPath, 'characters.txt')).readAsString()));

    // // List<String> tracksBmgContents =
    //     await File(path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt'))
    //         .readAsLines();
    // tracksBmgContents.removeRange(0, 4);
    String tracksBmgContents =
        await File(path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt'))
            .readAsString();

    // String editedContent =

    //     "${raceUcontentsTxt.split('270f	= ?')[0]}270f	= ?\n${tracksBmgContents.join('\n')}";
    String editedContent =
        "${raceUcontentsTxt.split('270f	= ?')[0]}270f	= ?\n${replaceCharacterNameInCommonTxt(packPath, replaceCommonBmgTextWithVanillaNames(tracksBmgContents, keepNintendo), await File(path.join(packPath, 'characters.txt')).readAsString())}";

    await raceUcommon.writeAsString(editedContent, mode: FileMode.write);

    await Process.run(
        'wbmgt',
        [
          'encode',
          path.join(
              packPath, 'Scene', 'UI', 'Race_U.szs.d', 'message', 'Common.txt'),
          '--dest',
          path.join(
              packPath, 'Scene', 'UI', 'Race_U.szs.d', 'message', 'Common.bmg'),
          '-o',
        ],
        runInShell: true);

    await Process.run(
        'wszst',
        [
          'create',
          path.join(packPath, 'Scene', 'UI', 'Race_U.szs.d'),
          '--overwrite',
          '--dest',
          path.join(packPath, 'Scene', 'UI', 'Race_U.szs'),
        ],
        runInShell: true);
    if (enableCustomChar) {
      setState(() {
        progressText = "patching ui files with custom characters";
      });
      for (SceneComplete scene in neededFiles) {
        String baseName =
            path.basename(getFileFromIndex(packPath, scene.index).path);
        await Process.run(
            'wszst',
            [
              'extract',
              path.join(packPath, 'Scene', 'UI', baseName),
              '--dest',
              "${path.join(packPath, 'Scene', 'UI', baseName)}.d",
            ],
            runInShell: true);

        await patchSzsWithImages(
            packPath,
            Directory(
              "${path.join(packPath, 'Scene', 'UI', baseName)}.d",
            ),
            customTxtContent,
            scene.index);
      }

      if (await File(path.join(packPath, 'Scene', 'UI', 'Award_U.szs'))
          .exists()) {
        await Process.run(
            'wszst',
            [
              'extract',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs'),
              '--dest',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d'),
            ],
            runInShell: true);
        await Process.run(
            'wbmgt',
            [
              'decode',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d', 'message',
                  'Common.bmg'),
              '--dest',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d', 'message',
                  'Common.txt'),
            ],
            runInShell: true);

        File awardCommonTxt = File(path.join(
            packPath, 'Scene', 'UI', 'Award_U.szs.d', 'message', 'Common.txt'));

        String awardContentsCommonTxt = await awardCommonTxt.readAsString();

        await awardCommonTxt.writeAsString(replaceCharacterNameInCommonTxt(
            packPath,
            awardContentsCommonTxt,
            await File(path.join(packPath, 'characters.txt')).readAsString()));
        await Process.run(
            'wbmgt',
            [
              'encode',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d', 'message',
                  'Common.txt'),
              '--overwrite',
              '--dest',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d', 'message',
                  'Common.bmg'),
            ],
            runInShell: true);
        await Process.run(
            'wszst',
            [
              'create',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs.d'),
              '--overwrite',
              '--dest',
              path.join(packPath, 'Scene', 'UI', 'Award_U.szs'),
            ],
            runInShell: true);
      }
    }
    for (SceneComplete scene in SceneComplete.values) {
      if (scene.index % 2 == 0) {
        File ogFile = getFileFromIndex(packPath, scene.index);
        if (!await File(
                path.join(packPath, 'Scene', 'UI', path.basename(ogFile.path)))
            .exists()) {
          await ogFile.copy(
              path.join(packPath, 'Scene', 'UI', path.basename(ogFile.path)));
        }
      }
    }
    for (FileSystemEntity file in await Directory(path.join(
            packPath, 'Scene', 'UI', path.join(packPath, 'Scene', 'UI')))
        .list()
        .toList()) {
      await Process.run(
          'wszst',
          [
            'patch',
            '--le-menu',
            //'--9laps',
            '--cup-icons',
            path.join(packPath, 'Icons', 'merged.png'),
            '--links',
            file.path,
            '--overwrite',
            '--dest',
            file.path
          ],
          runInShell: true);
    }
    List<String> allKartsList = [];
    List<String> driverBrresList = [];
    List<String> awardBrresList = [];
    List<String> customStrings = customTxtContent
        .where((element) => element.split(';')[1].isNotEmpty)
        .toList();
    List<String> charNames = [];
    if (enableCustomChar) {
      setState(() {
        progressText = "replacing vehicles files";
      });

      //extract /Scene/Model/Driver.szs
      for (String string in customStrings) {
        String name = string.split(';')[0];
        charNames.add(name);
        String customChar = string.split(';')[1];
        String pathOfCustomDir = getPathOfCustomCharacter(packPath, customChar);
        //sposta il file in Scene/Model/allkart.
        List<FileSystemEntity> allKarts = await Directory(pathOfCustomDir)
            .list()
            .where((files) => files.path.contains('allkart.szs'))
            .toList();
        List<File> drivers = (await Directory(pathOfCustomDir)
                .list()
                .where((files) => files.path.contains('driver.brres'))
                .toList())
            .whereType<File>()
            .toList();
        List<File> awards = (await Directory(pathOfCustomDir)
                .list()
                .where((files) => files.path.contains('award.brres'))
                .toList())
            .whereType<File>()
            .toList();
        if (drivers.isNotEmpty) {
          driverBrresList.add("${characters3D[name]}.brres");
          await drivers[0].copy(path.join(packPath, 'Scene', 'Model',
              'Driver.szs.d', "${characters3D[name]}.brres"));
        } else {
          logString(LogType.ERROR,
              '$pathOfCustomDir does not contain driver.brres. skipping.');
        }

        if (awards.isNotEmpty) {
          awardBrresList.add("${characters3D[name]}.brres");
          await awards[0].copy(path.join(
              packPath, 'Demo', 'Award.szs.d', "${characters3D[name]}.brres"));
        } else {
          logString(LogType.ERROR,
              '$pathOfCustomDir does not contain award.brres. skipping.');
        }

        if (allKarts.isNotEmpty) {
          await File(allKarts[0].path).copy(path.join(packPath, 'Scene',
              'Model', 'Kart', "${characters3D[name]}-allkart.szs"));
          allKartsList.add("${characters3D[name]}-allkart.szs");
        } else {
          logString(LogType.ERROR,
              '$pathOfCustomDir does not contain allkart.szs. skipping.');
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
            for (String extraName in characters3D.values) {
              cleanFileName = cleanFileName.replaceFirst("-$extraName.szs", '');
            }

            await file.copy(path.join(packPath, 'Race', 'Kart',
                "$cleanFileName-${characters3D[name]}.szs"));
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
    await Directory(path.join(packPath, 'Demo', 'Award.szs.d'))
        .delete(recursive: true);
    await Directory(path.join(packPath, 'Scene', 'Model', 'Driver.szs.d'))
        .delete(recursive: true);

    setState(() {
      progressText = "editing xml file";
      completeXmlFile(
          packPath,
          isOnline,
          regionId,
          customUI,
          Directory(path.join(packPath, 'Scene', 'UI'))
              .listSync()
              .whereType<File>()
              .toList(),
          allKartsList);
    });

    //     .deleteSync(recursive: true);
    await File(path.join(packPath, 'Icons', 'merged.png')).delete();
    // Directory(path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.d'))
    //     .deleteSync(recursive: true);
    // File(path.join(packPath, 'Scene', 'UI', 'MenuSingle_U.txt')).delete();
    // File(path.join(packPath, 'Scene', 'UI', 'tracks.bmg.txt')).delete();
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
      if (!filepath.endsWith("brstm") && Platform.isMacOS) {
        logString(LogType.ERROR, "cannot convert audio file on MacOS");
        return;
      }
      if (filepath.endsWith(".brstm")) {
        //if brstm file pair
        if (isFastBrstm(filepath)) {
          //if fast path
          //if fast file-> normal_file
          // final fastPart = RegExp(r'_[f,F]');
          // filepath = filepath.replaceFirst(fastPart, '');
        }
        // File normalFile = File(path.join(workspace, 'myMusic', filepath));
        // await normalFile.copy(path.join(musicDir.path, '$id.brstm'));
        File normalFile = Directory(path
                .join(path.join(workspace, 'myMusic', path.dirname(filepath))))
            .listSync()
            .whereType<File>()
            .firstWhere((element) =>
                !isFastBrstm(element.path) &&
                element.path.contains(path
                    .basename(filepath)
                    .replaceFirst(RegExp(r'_?[a-zA-Z]?\.brstm$'), '')));
        await normalFile.copy(path.join(musicDir.path, '$id.brstm'));

        File fastFile = Directory(path
                .join(path.join(workspace, 'myMusic', path.dirname(filepath))))
            .listSync()
            .whereType<File>()
            .firstWhere((element) =>
                isFastBrstm(element.path) &&
                element.path.contains(path
                    .basename(filepath)
                    .replaceFirst(RegExp(r'_?[a-zA-Z]?\.brstm$'), '')));

        await fastFile.copy(path.join(musicDir.path, '${id}_f.brstm'));
      } else {
        await fileToBrstm(
            path.join(workspace, "myMusic", filepath),
            path.join(packPath, "Music", "tmp"),
            path.join(packPath, "Music"),
            id);
      }
    }
    await tmpDir.delete(recursive: true);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Center(
                  child: Column(children: [
                patchStatus == PatchingStatus.running
                    ? Text("Patching...",
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.fontSize))
                    : patchStatus == PatchingStatus.completed
                        ? Text("Patch is completed",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.fontSize))
                        : const Text(''),
                if (patchStatus == PatchingStatus.running)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.amberAccent, size: 50),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            progressText,
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.fontSize),
                          ),
                        )
                      ],
                    ),
                  )
              ])),
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
            ])));
  }
}
