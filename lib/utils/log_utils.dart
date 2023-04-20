import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

Future<File> createLogFile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? workspace = prefs.getString('workspace');
  // ignore: prefer_conditional_assignment
  if (workspace == null) {
    workspace = "workspaceError";
  }
  File logFile = File(path.join(workspace, 'error.log'));

  if (workspace != "workspaceError" && !logFile.existsSync()) {
    logFile.createSync();
  }
  return logFile;
}

// ignore: constant_identifier_names
enum LogType { ERROR, INFO }

Future<void> logString(LogType type, String text) async {
  File logFile = await createLogFile();
  if (!logFile.existsSync()) return; //error creating logfile
  DateTime now = DateTime.now();
  DateTime date =
      DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  String line =
      "${type.name} [${date.toString().replaceRange(date.toString().length - 4, null, '')}] $text\n";
  logFile.writeAsStringSync(line, mode: FileMode.append);
}
