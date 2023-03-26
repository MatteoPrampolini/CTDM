import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../gui_elements/cub_table_header.dart';
import '../gui_elements/cup_table_row.dart';
import '../gui_elements/types.dart';

List<List<Track>> parseConfig(String configPath) {
  List<List<Track>> cups = [];
  File configFile = File(configPath);
  String contents = configFile.readAsStringSync();
  List<String> cupList = contents
      .split(r"N$F_WII")[1]
      .split(RegExp(r'^C.*[0-9]+', multiLine: true));

  cupList.removeAt(0);
  for (var cup in cupList) {
    cups.add(splitCupListsFromText(cup.trim()));
  }
  return cups;
}

List<Track> splitCupListsFromText(String str) {
  List<Track> trackList = [];
  //print(str);
  for (String line in str.split("\n")) {
    //print("line:|${line.trim()}|");
    trackList.add(parseTrackLine(line));
  }
  return trackList;
}

Track parseTrackLine(String trackLine) {
  Track tmp = Track('', 0, 0, '', TrackType.base);
  int i = 0;

  //return; //TODO
  for (String param in trackLine.split(r';')) {
    if (param.trim() == "") continue;
    //print("|${param.trim().replaceRange(0, 3, '')}|");
    switch (i) {
      case 0:
        //print(RegExp('[0-9]+').stringMatch(param));
        //param = param.trim().replaceRange(0, 2, '');
        //print(param);
        tmp.musicId = int.parse(RegExp('[0-9]+').stringMatch(param)!);
        break;
      case 1:
        tmp.slotId = int.parse(RegExp('[0-9]+').stringMatch(param)!);
        break;
      case 2:
        switch (param.trim()) {
          case "0x00":
            tmp.type = TrackType.base;
            break;
          case "0x02":
            tmp.type = TrackType.menu;
            break;
          case "0x04":
            tmp.type = TrackType.hidden;
            break;
        }
        break;
      case 3:
        tmp.path = param.trim().replaceAll('"', '');
        break;
      case 4:
        tmp.name = param.trim().replaceAll('"', '');

        break;
    }
    i++;
  }
  return tmp;
}

class TrackConfigGui extends StatefulWidget {
  final String packPath;
  const TrackConfigGui(this.packPath, {super.key});

  @override
  State<TrackConfigGui> createState() => _TrackConfigGuiState();
}

class _TrackConfigGuiState extends State<TrackConfigGui> {
  late List<List<Track>> cups = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      cups = parseConfig(path.join(widget.packPath, 'config.txt'));
      print(cups.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track config GUI",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: SingleChildScrollView(
          controller: AdjustableScrollController(80),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cups.length; i++)
                  CupTable(i + 1, cups[i], widget.packPath),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 2 - 100),
                  child: ElevatedButton(
                    child: Text("Add cup"),
                    onPressed: () => {
                      setState(() => {cups.add([])})
                    },
                  ),
                )
              ]),
        ));
  }
}

class CupTable extends StatefulWidget {
  late int cupIndex;
  late String packPath;
  late List<Track> cup;
  CupTable(this.cupIndex, this.cup, this.packPath, {super.key});

  @override
  State<CupTable> createState() => _CupTableState();
}

class _CupTableState extends State<CupTable> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(top: 40, bottom: 40, left: 100, right: 100),
        child: Column(children: [
          CupTableHeader(widget.cupIndex, widget.packPath),
          for (var track
              in widget.cup.where((element) => element.type == TrackType.base))
            CupTableRow(track, widget.packPath)
        ]));
  }
}
