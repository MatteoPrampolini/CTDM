import 'dart:io';
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
  Process.run(dolphinPath, ['-e', presetPath, '-b'], runInShell: false);
  // print(p.stderr);
  // print(p.stdout);
  //return p.pid.toString();
  return "";
}
