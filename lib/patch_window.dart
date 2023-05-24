import 'dart:io';
import 'dart:ui' as ui;
import 'package:ctdm/drawer_options/cup_icons.dart';
import 'package:ctdm/utils/gecko_utils.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:ctdm/utils/music_utils.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merge_images/merge_images.dart';
import 'package:path/path.dart' as path;

//import 'package:image/image.dart' as img;

class PatchWindow extends StatefulWidget {
  final String packPath;
  const PatchWindow(this.packPath, {super.key});

  @override
  State<PatchWindow> createState() => _PatchWindowState();
}

enum PatchingStatus { aborted, running, completed }

void completeXmlFile(String packPath) {
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
  Directory courseDir = Directory(path.join(packPath, 'Race', 'Course'));
  String courseBigString = "";
  List<File> courseDirList = courseDir.listSync().whereType<File>().toList();
  for (File course in courseDirList) {
    courseBigString +=
        '<file external="/$packName/Race/Course/${path.basename(course.path)}" disc="/Race/Course/${path.basename(course.path)}" create="true"/>\n\t\t';
  }
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
  contents = contents.replaceFirst(
      RegExp(r'<!--MY COMMONS-->.*<!--END MY TRACKS-->', dotAll: true),
      '<!--MY COMMONS-->\n\t\t$commonBigString$courseBigString<!--END MY TRACKS-->\t\t');
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
  if (!Directory(path.join(packPath, 'Race', 'Course')).existsSync()) {
    Directory(path.join(packPath, 'Race', 'Course')).createSync();
  }
  if (!Directory(path.join(packPath, 'Race', 'Common')).existsSync()) {
    Directory(path.join(packPath, 'Race', 'Common')).createSync();
  }
  if (!Directory(path.join(packPath, 'rel')).existsSync()) {
    Directory(path.join(packPath, 'rel')).createSync();
  }
  if (!Directory(path.join(packPath, 'Scene')).existsSync()) {
    Directory(path.join(packPath, 'Scene')).createSync();
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
  for (var file in Directory(path.join(packPath, 'sys')).listSync()) {
    file.deleteSync(recursive: true);
  }
  Directory(path.join(packPath, 'sys', 'P')).createSync();
  Directory(path.join(packPath, 'sys', 'E')).createSync();
  Directory(path.join(packPath, 'sys', 'J')).createSync();
  Directory(path.join(packPath, 'sys', 'K')).createSync();
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
  File trackFile = File(path.join(packPath, 'Scene', 'tracks.bmg.txt'));
  if (await trackFile.exists()) {
    await trackFile.delete();
  }
  try {
    await Process.run(
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
    return path.join(packPath, 'Scene', 'tracks.bmg.txt');
    //return parseBMGList(packPath);
  } on Exception catch (_) {
    logString(LogType.ERROR, _.toString());
    rethrow;
  }
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
///At the end of the execution MenuSingle_E.szs will be patched with the new bmgs.
Future<void> editMenuSingle(String workspace, String packPath) async {
  //copy MenuSingle_E.szs
  final File origMenuFile = File(path.join(
      path.dirname(Platform.resolvedExecutable),
      "data",
      "flutter_assets",
      "assets",
      "scene",
      "MenuSingle_E.szs"));
  await origMenuFile.copy(path.join(packPath, 'Scene', 'MenuSingle_E.szs'));
  //create tracks.bmg.txt
  final File trackBmgTxt = File(await createBMGList(packPath));
  try {
    //  wbmgt decode MenuSingle_E.szs --dest MenuSingle_E.txt
    await Process.run(
        'wbmgt',
        [
          'decode',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.txt'),
        ],
        runInShell: false);
    //MenuSingle_E.szs (file) extract  -> MenuSingle_E.d (folder)
    await Process.run(
        'wszst',
        [
          'extract',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.d'),
        ],
        runInShell: false);
    //edit MenuSingle_E.txt with tracks.bmg.txt content
    String contents = await trackBmgTxt.readAsString();
    contents = contents.replaceAll(RegExp(r'#BMG'), '');
    File editedMenuFile =
        File(path.join(packPath, 'Scene', 'MenuSingle_E.txt'));
    await editedMenuFile.writeAsString(contents, mode: FileMode.append);
    //MenuSingle_E.txt -> Common.bmg (MenuSingle_E.d/Common.bmg)
    //  wbmgt encode MenuSingle_E.txt

    await Process.run(
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
    //MenuSingle_E.szs (file) <- compact MenuSingle_E.d (folder)
    await Process.run(
        'wszst',
        [
          'create',
          path.join(packPath, 'Scene', 'MenuSingle_E.d'),
          '--overwrite',
          '--dest',
          path.join(packPath, 'Scene', 'MenuSingle_E.szs'),
        ],
        runInShell: false);
  } on Exception catch (_) {
    logString(LogType.ERROR, _.toString());
    rethrow;
  }
}

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
      File(path.join(packPath, 'Scene', 'tracks.bmg.txt')).readAsLinesSync();

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
///Note: Do not confuse MenuSingle.szs with MenuSingle_E.szs.
Future<void> patchIcons(String workspace, String packPath) async {
  final File origSingle = File(path.join(
      workspace, 'ORIGINAL_DISC', 'files', 'Scene', 'UI', 'MenuSingle.szs'));

  origSingle.copySync(path.join(packPath, 'Scene', 'MenuSingle.szs'));

  Directory iconDir = Directory(path.join(packPath, 'Icons'));
  int nCups = getNumberOfIconsFromConfig(packPath);
  if (iconDir.listSync().whereType<File>().length < nCups + 2) {
    logString(LogType.ERROR, "not enough icons to patch");
    return;
  }
  //wszst patch MenuSingle.szs --le-menu --cup-icons ./icons.tpl --links
  try {
    await createBigImage(iconDir, nCups).then((value) => {
          Process.runSync(
              'wszst',
              [
                'patch',
                '--le-menu',
                '--cup-icons',
                path.join(packPath, 'Icons', 'merged.png'),
                '--links',
                path.join(packPath, 'Scene', 'MenuSingle.szs'),
                '--overwrite',
                '--dest',
                path.join(packPath, 'Scene', 'MenuSingle.szs'),
              ],
              runInShell: false),
        });
  } on Exception catch (_) {
    logString(LogType.ERROR, _.toString());
    rethrow;
  }
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
      int.tryParse(path.basenameWithoutExtension(b.path)) != null) {
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
  @override
  void initState() {
    patch(widget.packPath);
    super.initState();
  }

  void patch(String packPath) async {
    patchStatus = PatchingStatus.running;
    //create folders
    createFolders(packPath);

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
    await patchIcons(workspace, packPath);
    setState(() {
      progressText = "patching singleplayer menu";
    });
    //patch MenuSingle_E.szs with the new bmgs.
    await editMenuSingle(workspace, packPath);

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
      try {
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
      } on Exception catch (_) {
        logString(LogType.ERROR, _.toString());
        rethrow;
        //print(_);
      }
      //needed?
      await Directory(path.join(packPath, 'Race', 'Course', 'tmp'))
          .delete(recursive: true);
    }

    //move main.dol and patch it with gecko codes
    setState(() {
      progressText = "patching main.dol";
    });
    for (GameVersion gv in fileMap.keys) {
      String letter = getLetterFromGameVersion(gv);
      File dolFile = File(path.join(path.dirname(Platform.resolvedExecutable),
          "data", "flutter_assets", "assets", "dols", "$letter.dol"));
      if (await File(path.join(packPath, 'sys', letter, "main.dol")).exists()) {
        await File(path.join(packPath, 'sys', letter, "main.dol")).delete();
      }
      await dolFile.copy(path.join(packPath, 'sys', letter, "main.dol"));
      try {
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
      } on Exception catch (_) {
        //print(_);
        logString(LogType.ERROR, _.toString());
        rethrow;
      }
    }

    //copy music
    setState(() {
      progressText = "creating music files (if any)";
    });
    await copyMusic(workspace, packPath);
    //await Future.delayed(const Duration(seconds: 1));
    setState(() {
      progressText = "editing xml file";
      completeXmlFile(packPath);
    });
    setState(() {
      progressText = "deleting tmp files";
    });
    await Future.delayed(const Duration(seconds: 1));
    File(path.join(packPath, 'Icons', 'merged.png')).delete();
    Directory(path.join(packPath, 'Scene', 'MenuSingle_E.d'))
        .deleteSync(recursive: true);
    File(path.join(packPath, 'Scene', 'MenuSingle_E.txt')).delete();
    File(path.join(packPath, 'Scene', 'tracks.bmg.txt')).delete();
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
        if (isFastBrstm(filepath)) {
          //if fast file-> normal_file
          final fastPart = RegExp(r'_[f,F]');
          filepath = filepath.replaceFirst(fastPart, '');
        }
        File normalFile = File(path.join(workspace, 'myMusic', filepath));
        await normalFile.copy(path.join(musicDir.path, '$id.brstm'));

        File fastFile = Directory(path
                .join(path.join(workspace, 'myMusic', path.dirname(filepath))))
            .listSync()
            .whereType<File>()
            .firstWhere((element) =>
                isFastBrstm(element.path) &&
                element.path.contains(path.basenameWithoutExtension(filepath)));

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
