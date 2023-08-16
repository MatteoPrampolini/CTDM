import 'dart:io';
import 'package:ctdm/drawer_options/rename_pack.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

Future<String> zipPack(List<String> parameters) async {
  String packPath = parameters[0];
  final dirToZip = [
    'codes',
    'Demo',
    'Race',
    'static',
    'thp',
  ];
  final archive = Archive();

  for (final targetDirName in dirToZip) {
    final targetDir = Directory('$packPath/$targetDirName');
    if (await targetDir.exists()) {
      final fileList = await _getFileListInDirectory(targetDir);
      for (final file in fileList) {
        final relativePath = path.join(
            targetDirName, path.relative(file.path, from: targetDir.path));
        final fileContent = await file.readAsBytes();
        final archiveFile =
            ArchiveFile(relativePath, fileContent.length, fileContent);
        archive.addFile(archiveFile);
      }
    }
  }
  const riivolutionDir = 'riivolution';
  final xmlFile = File(
      path.join(packPath, '${path.basenameWithoutExtension(packPath)}.xml'));
  if (await xmlFile.exists()) {
    final xmlFileContent = await xmlFile.readAsBytes();
    final archiveFile = ArchiveFile(
        path.join(riivolutionDir, '${path.basename(packPath)}.xml'),
        xmlFileContent.length,
        xmlFileContent);
    archive.addFile(archiveFile);
  }

  final zipFileName = path.join(packPath, "${path.basename(packPath)}.zip");
  final zipFile = File(zipFileName);
  final zipFileBytes = ZipEncoder().encode(archive);
  await zipFile.writeAsBytes(zipFileBytes!);

  return zipFileName;
}

Future<List<File>> _getFileListInDirectory(Directory directory) async {
  final fileList = <File>[];
  final lister = directory.list(recursive: true);
  await for (final entity in lister) {
    if (entity is File) {
      fileList.add(entity);
    }
  }
  return fileList;
}

Future<String> runOnDolphin(List<String> parameters) async {
  String dolphinPath = parameters[0];
  String presetPath = parameters[1];
  String packPath = parameters[2];
  String game = parameters[3];
  bool errorFound = false;
  //dolphin checks
  if (!File(dolphinPath).existsSync()) {
    logString(
        LogType.ERROR, 'Dolphin executable not found. Go to CTDM settings.');
    errorFound = true;
  } else {
    FileStat fileStat = await File(dolphinPath).stat();
    bool isExecutable = (fileStat.mode & 0x1) > 0;
    if (!isExecutable) {
      logString(LogType.ERROR, 'Dolphin executable cannot be run.');
      errorFound = true;
    }
  }
  //game checks
  if (!File(game).existsSync()) {
    logString(LogType.ERROR, 'Game iso was not found. Go to CTDM settings.');
    errorFound = true;
  }
  if (errorFound) {
    return "An error occurred. Check your CTDM settings.";
  }
  var (packName, packId) = getPackNameAndId(packPath);
  replaceParamsInJson(File(path.join(packPath, "$packName.json")), packName,
      packId, game, dolphinPath);
  Process.run(dolphinPath, ['-e', presetPath, '-b'], runInShell: false);
  // print(p.stderr);
  // print(p.stdout);
  //return p.pid.toString();
  return "";
}
