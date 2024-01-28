import 'dart:io';
import 'package:ctdm/drawer_options/track_config_gui.dart';
import 'package:ctdm/gui_elements/types.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ctdm/pack_editor.dart';

void createExcelFromTextFile(String textFilePath, String excelFilePath) {
  final textFile = File(textFilePath);
  final lines = textFile.readAsLinesSync();

  final excel = Excel.createExcel();

  final sheet = excel['Sheet1'];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final cells = line.split('\t');

    for (var j = 0; j < cells.length; j++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i))
          .value = cells[j];
    }
  }

  var fileBytes = excel.save();
  File(excelFilePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(fileBytes!);
}

// void main() {
//   const textFilePath =
//       r'C:\Users\matte\Documents\CT_test\CTDM_workspace\Packs\Tutorial\config.txt';
//   const excelFilePath =
//       r'C:\Users\matte\Documents\CT_test\CTDM_workspace\Packs\Tutorial\config.xlsx';

//   File configFile = File(textFilePath);
//   var fileBytes = cupsToExcel(parseConfig(configFile));
//   File(excelFilePath)
//     ..createSync(recursive: true)
//     ..writeAsBytesSync(fileBytes!);
//   print('Exel created!');
// }
void exportToExcel(String packPath, BuildContext context) {
  File configFile = File(path.join(packPath, 'config.txt'));
  String excelPath = path.join(packPath, '${path.basename(packPath)}.xlsx');
  List<Cup> cups = parseConfig(configFile.path);
  for (var i = 0; i < cups.length; i++) {
    if (cups[i].cupName.isEmpty) {
      cups[i].cupName = "Cup #${i + 1}";
    }
  }

  try {
    var fileBytes = cupsToExcel(cups);
    File(excelPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    showResultModal(context, "Done",
        "${path.basename(packPath)}.xlsx created succesfully.");
  } on Exception catch (_) {
    logString(LogType.ERROR, _.toString());
    showResultModal(
        context, "Done", "Cannot create ${path.basename(packPath)}.xlsx");
  }
}

// List<Cup> parseConfig(File configFile) {
//   List<Cup> cups = [];
//   String contents = configFile.readAsStringSync();
//   List<String> cupList = contents
//       .split(r"N$F_WII")[1]
//       .split(RegExp(r'^C.*[0-9]?', multiLine: true));

//   List<String> cupNames = contents
//       .split(r"N$F_WII")[1]
//       .split("\n")
//       .where((element) => element.startsWith('C'))
//       .toList();
//   cupList.removeAt(0);

//   int i = 0;
//   String tmpName = "";
//   for (String cupString in cupList) {
//     if (cupNames[i].length > 1) {
//       tmpName = cupNames[i].replaceRange(0, 2, '');
//     } else {
//       tmpName = "";
//     }
//     cups.add(Cup(tmpName, splitCupListsFromText(cupString.trim())));
//     i++;
//   }
//   return cups;
// }

List<Cup> parseConfig(String configPath) {
  //List<List<Track>> cups = [];
  List<Cup> cups = [];
  File configFile = File(configPath);
  String contents = configFile.readAsStringSync();
  String arenaTxt = "";
  if (contents.contains('[SETUP-ARENA]')) {
    arenaTxt = contents.split('[SETUP-ARENA]').last;
    contents = contents.split('[SETUP-ARENA]').first;
  }
  List<String> cupList = contents
      .split(r"N$F_WII")[1]
      .split(RegExp(r'^C.*[0-9]?', multiLine: true));

  List<String> cupNames = contents
      .split(r"N$F_WII")[1]
      .split("\n")
      .where((element) => element.startsWith('C'))
      .toList();

  cupList.removeAt(0);

  int i = 0;
  String tmpName = "";
  for (String cupString in cupList) {
    if (cupNames[i].length > 1) {
      tmpName = cupNames[i].replaceRange(0, 2, '');
    } else {
      tmpName = "";
    }
    cups.add(Cup(tmpName, splitCupListsFromText(cupString.trim())));
    i++;
  }
  cups.addAll(parseArenaTxt(arenaTxt));
  return cups;
}

List<int>? cupsToExcel(List<Cup> cups) {
  var excel = Excel.createExcel();

  excel.rename('Sheet1', 'Cups');
  Sheet sheet = excel['Cups'];
  var headerRow = [
    "Name",
    "Track Slot",
    "Music Slot",
    "File Path",
    "Type",
    "Music File",
    "Cup"
  ];
  sheet.appendRow(headerRow);
  //var rowIndex = 1;
  for (var i = 0; i < cups.length; i++) {
    final cup = cups[i];

    // rowIndex++;
    // sheet.merge(
    //     CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    //     CellIndex.indexByColumnRow(
    //         columnIndex: cups[0].tracks.length, rowIndex: rowIndex));
    // var cell = sheet
    //     .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
    // cell.value = cup.cupName != "" ? cup.cupName : "Cup #${i + 1}";
    // cell.cellStyle = CellStyle(
    //   backgroundColorHex: '#00FF00',
    //);

    for (var j = 0; j < cup.tracks.length; j++) {
      final track = cup.tracks[j];

      final rowData = [
        track.name,
        track.slotId,
        track.musicId,
        track.path,
        track.type.toString().split('.').last,
        track.musicFolder ?? '',
        cup.cupName.replaceAll(r'"', "")
      ];

      sheet.appendRow(rowData);
      //rowIndex++;

      // CellStyle cellStyle = CellStyle();

      // switch (track.type) {
      //   case TrackType.menu:
      //     cellStyle.backgroundColor = 'ffff00'; //yellow
      //     break;
      //   case TrackType.hidden:
      //     cellStyle.backgroundColor = 'ffbf00'; //amber
      //     break;
      //   default:
      //     break;
      // }
      // for (var k = 0; k < rowData.length; k++) {
      //   var cell = sheet.cell(
      //       CellIndex.indexByColumnRow(columnIndex: k, rowIndex: rowIndex));
      //   cell.cellStyle = cellStyle;
      // }
    }
  }

  return excel.save();
}
