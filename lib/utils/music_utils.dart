import 'dart:convert';
import 'dart:io';

import 'package:ctdm/utils/exceptions_utils.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:path/path.dart' as path;

bool isFastBrstm(String path) {
  return path.endsWith('_f.brstm') ||
      path.endsWith('_F.brstm') ||
      path.endsWith('_f.wav') ||
      path.endsWith('_F.wav');
}

bool isFfmpegInstalled() {
  try {
    ProcessResult res =
        Process.runSync('ffmpeg', ['-version'], runInShell: false);
    return res.exitCode == 0;
  } on Exception catch (_) {
    logString(LogType.ERROR,
        "ffmpeg not found. please install it and add it to PATH https://ffmpeg.org/download.html");
    return false;
  }
}

bool isMpvInstalled() {
  try {
    ProcessResult res =
        Process.runSync('mpv', ['--version'], runInShell: false);
    return res.exitCode == 0;
  } on Exception catch (_) {
    logString(LogType.ERROR,
        "mpv.io not found. please install it and add it to PATH https://mpv.io/installation/.");
    return false;
  }
}

Future<void> audioFileToBrstmPair(File input, String outputFolder) async {
  if (!Platform.isWindows && !Platform.isLinux) {
    logString(LogType.ERROR, "Cannot convert file. Use windows or linux.");
    return;
  }
  if (!await Directory(outputFolder).exists()) {
    await Directory(outputFolder).create();
  }
  String normalizeFilePath =
      path.join(outputFolder, "NORMALIZE_${path.basename(input.path)}");
  File normalizeFile = await normalize(input, File(normalizeFilePath));
  String tmpFilePath =
      "${path.join(outputFolder, path.basenameWithoutExtension(input.path))}.wav";

  String tmpFilePathFast =
      "${path.join(outputFolder, path.basenameWithoutExtension(input.path))}_f.wav";

  double maxVolume = await getMaxVolumePeak(File(normalizeFile.path));
  File normalFile = await audioToWavAdpcm(
      normalizeFile.path, tmpFilePath, maxVolume); //create wav

  File fastFile = await createFastCopy(normalFile.path, tmpFilePathFast);
  //create fast wav
  await wavToBrstm(normalFile.path, outputFolder,
      path.basenameWithoutExtension(normalFile.path));

  await wavToBrstm(fastFile.path, outputFolder,
      path.basenameWithoutExtension(fastFile.path));

  if (await normalFile.exists()) {
    await normalFile.delete();
  }
  if (await File(normalizeFilePath).exists()) {
    await File(normalizeFilePath).delete();
  }
  if (await File(tmpFilePath).exists()) {
    await File(tmpFilePath).delete();
  }
  if (await File(tmpFilePathFast).exists()) {
    await File(tmpFilePathFast).delete();
  }
}

///Takes an audio file (mp3,wav) and converts it in 2 brstm files.
///
///id is the hex id of the track associated with this music
///
Future<void> fileToBrstm(
    String inputPath, String tmpFolder, String outputFolder, String id) async {
  if (!Platform.isWindows && !Platform.isLinux) {
    logString(LogType.ERROR, "Cannot convert file. Use windows or linux.");
    return;
  }
  File normalizeFile = await normalize(File(inputPath),
      File(path.join(tmpFolder, "NORMALIZE_${path.basename(inputPath)}")));
  String tmpFilePath =
      "${path.join(tmpFolder, path.basenameWithoutExtension(inputPath))}.wav";

  String tmpFilePathFast =
      "${path.join(tmpFolder, path.basenameWithoutExtension(inputPath))}_f.wav";

  double maxVolume = await getMaxVolumePeak(File(normalizeFile.path));
  File normalFile = await audioToWavAdpcm(
      normalizeFile.path, tmpFilePath, maxVolume); //create wav

  File fastFile = await createFastCopy(normalFile.path, tmpFilePathFast);
  //create fast wav
  await callBrstmConverter(
      normalFile.path, outputFolder, id, isFastBrstm(tmpFilePath));

  await callBrstmConverter(
      fastFile.path, outputFolder, id, isFastBrstm(tmpFilePathFast));
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

Future<File> audioToWavAdpcm(
    String inputPath, String tmpFilePath, double maxVolume) async {
  double targetDb = 2.5;
  double dbIncrease = (targetDb - maxVolume);
  //print(dbIncrease);
  await Process.run(
      'ffmpeg',
      [
        '-y',
        '-i',
        inputPath,
        '-filter:a',
        "volume=$dbIncrease",
        '-acodec',
        'pcm_s16le',
        tmpFilePath
      ],
      runInShell: true);
  return File(tmpFilePath);
}

Future<File> createFastCopy(String tmpFilePath, String tmpFilePathFast) async {
  await Process.run(
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
  return File(tmpFilePathFast);
}

Future<void> wavToBrstm(
    String inputPath, String outputFolder, String outputBasename,
    {int loopPoint = 0}) async {
  outputBasename = path.basenameWithoutExtension(outputBasename);
  final String executablesFolder = File(path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "executables"))
      .path;
  if (Platform.isWindows) {
    await Process.run(
        'set',
        [
          '__COMPAT_LAYER=Win8RTM',
          '&',
          path.join(executablesFolder, 'brstm_converter-amd64-windows.exe'),
          inputPath,
          '-o',
          path.join(outputFolder, "$outputBasename.brstm"),
          '-l',
          loopPoint.toString(),
        ],
        runInShell: true);
  } else if (Platform.isLinux) {
    await Process.run(
        path.join(executablesFolder, 'brstm_converter-amd64-linux'),
        [
          inputPath,
          '-o',
          path.join(outputFolder, "$outputBasename.brstm"),
          '-l',
          loopPoint.toString(),
        ],
        runInShell: true);
    return;
  } else {
    throw (Exception("wavToBrstm() cannot be called with this os."));
  }
}

Future<void> callBrstmConverter(
    String filePath, String outputFolder, String id, bool isFast) async {
  //print("$filePath exists: ${await File(filePath).exists()}");
  // String loopPoint = await getLoopPoint(File(
  //     filePath)); //not needed due to automaticBrsarPatching.json, yet a nice touch
  //print("${path.basename(filePath)}: $loopPoint");
  // print(loopPoint);
  // print(filePath);
  String loopPoint = "0";
  // // print(loopPoint);

  //print(await getLoopPoint(File(filePath)));
  //String loopPoint = '40000';
  // print("fake loopoint: $loopPoint");

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
    await Process.run(
        'set',
        [
          '__COMPAT_LAYER=Win8RTM',
          '&',
          path.join(executablesFolder, 'brstm_converter-amd64-windows.exe'),
          filePath,
          '-o',
          path.join(outputFolder, "$id$extra.brstm"),
          '-l',
          loopPoint,
        ],
        runInShell: true);
  } else if (Platform.isLinux) {
    await Process.run(
        path.join(executablesFolder, 'brstm_converter-amd64-linux'),
        [
          filePath,
          '-o',
          path.join(outputFolder, "$id$extra.brstm"),
          '-l',
          loopPoint,
        ],
        runInShell: true);
    return;
  } else {
    throw (Exception("callBrstmConverter() cannot be called with this os."));
  }
}

Future<String> getLoopPoint(File input) async {
  final String executablesFolder = File(path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "executables"))
      .path;
  // ProcessResult p = await Process.run(
  //     'ffmpeg',
  //     [
  //       '-i',
  //       input.path,
  //       '-filter:a',
  //       'volumedetect',
  //       '-f',
  //       'null',
  //       '/dev/null'
  //     ],
  //     runInShell: true);
  // String nSampleString =
  //     p.stderr.toString().split("n_samples:")[1].split("\n")[0].trim();
  // return (int.parse(nSampleString) / 2 - 1).toInt().toString();
  // ProcessResult p = await Process.run(
  //     'ffprobe',
  //     [
  //       '-select_streams',
  //       'a',
  //       '-show_streams',
  //       input.path,
  //     ],
  //     runInShell: true);

  // double duration =
  //     double.parse(p.stdout.toString().split("duration=")[1].split("\n")[0]);
  // int sampleRate =
  //     int.parse(p.stdout.toString().split("sample_rate=")[1].split("\n")[0]);

  // return (duration * sampleRate).floor() - 1000;
  ProcessResult p;
  if (Platform.isWindows) {
    p = await Process.run(
        'set',
        [
          '__COMPAT_LAYER=Win8RTM',
          '&',
          path.join(executablesFolder, 'brstm_converter-amd64-windows.exe'),
          input.path,
        ],
        runInShell: true);
  } else if (Platform.isLinux) {
    p = await Process.run(
        path.join(executablesFolder, 'brstm_converter-amd64-linux'),
        [
          input.path,
        ],
        runInShell: true);
  } else {
    throw Exception("cannot execute brstm_converter on this platform.");
  }

  int nSamples =
      int.parse(p.stdout.toString().split("Total samples:")[1].split("\n")[0]) -
          1;
  return nSamples.toString();
}

Future<double> getMaxVolumePeak(File input) async {
  ProcessResult p = await Process.run(
      'ffmpeg',
      [
        '-i',
        input.path,
        '-filter:a',
        'volumedetect',
        '-f',
        'null',
        '/dev/null'
      ],
      runInShell: true);
  double maxVolume = double.parse(p.stderr
      .toString()
      .split("max_volume:")[1]
      .split("\n")[0]
      .trim()
      .replaceAll(" dB", ""));
  //print("${path.basename(input.path)} volume: $maxVolume");
  return maxVolume;
}

Future<File> _runCommandToNormalize(
    File inputFile, File outputFile, String inputString) async {
  try {
    String parsedString =
        "{${(RegExp(r'\{([^}]+)\}').firstMatch(inputString)!.group(1))}}";

    Map<String, dynamic> data = json.decode(parsedString);

    String measuredI = data["input_i"];
    String measuredTP = data["input_tp"];
    String measuredLRA = data["input_lra"];
    double targetOffset =
        0.0; // Imposta l'offset su 0.0 come valore predefinito

    // Calcola il valore della soglia di loudness
    String measuredThreshold =
        (double.parse(measuredI) - double.parse(measuredLRA)).toString();
    String inputFilePath = inputFile.path;
    String outputFilePath = outputFile.path;

    List<String> ffmpegArgs = [
      '-i',
      inputFilePath,
      '-af',
      'loudnorm=I=-5.0:lra=1:tp=-0.0'
          ':measured_I=$measuredI:measured_LRA=$measuredLRA:measured_TP=$measuredTP'
          ':measured_thresh=$measuredThreshold:offset=${targetOffset.toStringAsFixed(2)}:linear=true',
      outputFilePath,
    ];

    await Process.run('ffmpeg', ffmpegArgs, runInShell: true);
  } catch (e) {
    logString(
        LogType.ERROR, "ERROR 5503: Cannot parse ffmpeg.\n${e.toString()}");
    throw CtdmException(inputString, StackTrace.current, "5503");
  }
  return outputFile;
}

Future<File> normalize(File inputFile, File output) async {
  ProcessResult p = await Process.run(
    'ffmpeg',
    [
      '-i',
      inputFile.path,
      '-af',
      "loudnorm=print_format=json",
      '-f',
      'null',
      '/dev/null',
      '-hide_banner',
    ],
  );

  String jsonString =
      "{${p.stderr.toString().split('[Parsed_loudnorm')[1].split('{')[1]}";

  return _runCommandToNormalize(inputFile, output, jsonString);
}
