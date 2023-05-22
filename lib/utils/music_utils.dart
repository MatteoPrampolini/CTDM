import 'dart:io';

import 'package:ctdm/utils/log_utils.dart';
import 'package:path/path.dart' as path;

bool isFastBrstm(String path) {
  final fastRegex = RegExp(r'.*_[f,F].+$');
  return fastRegex.hasMatch(path);
}

bool isFfmpegInstalled() {
  try {
    ProcessResult res =
        Process.runSync('ffmpeg', ['-version'], runInShell: false);
    return res.exitCode == 0;
  } on Exception catch (_) {
    logString(LogType.ERROR, "ffmpeg not found. please install it.");
    return false;
    //rethrow;
  }
}

///Takes an audio file (mp3,wav) and converts it in 2 brstm files.
///
///id is the hex id of the track associated with this music
Future<void> fileToBrstm(
    String inputPath, String tmpFolder, String outputFolder, String id) async {
  if (!Platform.isWindows && !Platform.isLinux) {
    logString(LogType.ERROR, "Cannot convert file. Use windows or linux.");
    return;
  }
  String tmpFilePath =
      "${path.join(tmpFolder, path.basenameWithoutExtension(inputPath))}.wav";

  String tmpFilePathFast =
      "${path.join(tmpFolder, path.basenameWithoutExtension(inputPath))}_f.wav";

  await audioToWavAdpcm(inputPath, tmpFilePath);
  await createFastCopy(tmpFilePath, tmpFilePathFast);
  await callBrstmConverter(
      tmpFilePath, outputFolder, id, isFastBrstm(tmpFilePath));
  await callBrstmConverter(
      tmpFilePathFast, outputFolder, id, isFastBrstm(tmpFilePathFast));
}

giveExecPermissionToBrstmConverter() async {
  final String executablesFolder = File(path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "executables"))
      .path;
  try {
    await Process.run('chmod',
        ['+x', path.join(executablesFolder, 'brstm_converter-amd64-linux')]);
    return;
  } on Exception catch (_) {
    logString(LogType.ERROR,
        "cannot give +x pemission to brstm_converter-amd64-linux");
    return;
  }
}

Future<void> audioToWavAdpcm(String inputPath, String tmpFilePath) async {
  try {
    await Process.run(
        'ffmpeg',
        [
          '-y',
          '-i',
          inputPath,
          '-filter:a',
          'volume=5.0',
          '-acodec',
          'pcm_s16le',
          '-ar',
          '44100',
          tmpFilePath
        ],
        runInShell: true);
    return;
  } on Exception catch (_) {
    logString(LogType.ERROR,
        "cannot convert file to adpcm ${path.basename(inputPath)}");
    return;
  }
}

Future<void> createFastCopy(String tmpFilePath, String tmpFilePathFast) async {
  try {
    Process.run(
        'ffmpeg',
        [
          '-y',
          '-i',
          tmpFilePath,
          '-filter:a',
          'atempo=1.1',
          '-vn',
          tmpFilePathFast
        ],
        runInShell: true);
    return;
  } on Exception catch (_) {
    logString(
        LogType.ERROR, "cannot speed up file ${path.basename(tmpFilePath)}");
    return;
  }
}

Future<void> callBrstmConverter(
    String filePath, String outputFolder, String id, bool isFast) async {
  String extra = "";
  if (isFast) extra = "_f";
  final String executablesFolder = File(path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "executables"))
      .path;
  if (Platform.isWindows) {
    try {
      await Process.run(
          'set',
          [
            '__COMPAT_LAYER=Win8RTM',
            '&',
            path.join(executablesFolder, 'brstm_converter-amd64-windows.exe'),
            filePath,
            '-o',
            path.join(outputFolder, "$id$extra.brstm")
          ],
          runInShell: true);

      return;
    } on Exception catch (_) {
      logString(LogType.ERROR,
          "cannot convert file ${path.basename(filePath)} to brstm");
      return;
    }
  } else if (Platform.isLinux) {
    try {
      await Process.run(
          path.join(executablesFolder, 'brstm_converter-amd64-linux'),
          [filePath, '-o', path.join(outputFolder, "$id$extra.brstm")],
          runInShell: true);
      return;
    } on Exception catch (_) {
      logString(LogType.ERROR,
          "cannot convert file ${path.basename(filePath)} to brstm");
      return;
    }
  }
}
