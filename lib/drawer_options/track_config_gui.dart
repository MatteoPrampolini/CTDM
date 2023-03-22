import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;

List<List<Track>> parseConfig(String configPath) {
  List<List<Track>> cups = [];
  File configFile = File(configPath);
  String contents = configFile.readAsStringSync();
  List<String> cupList =
      contents.split(r"N$F_WII")[1].split(RegExp(r'C.*[0-9]+'));

  cupList.removeAt(0);
  //print(cupList);

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
  Track tmp = Track('', 0, 0, '');
  int i = 0;
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

class trackConfigGUI extends StatefulWidget {
  final String packPath;
  const trackConfigGUI(this.packPath, {super.key});

  @override
  State<trackConfigGUI> createState() => _trackConfigGUIState();
}

class _trackConfigGUIState extends State<trackConfigGUI> {
  late List<List<Track>> cups;
  @override
  void initState() {
    super.initState();
    setState(() {
      cups = parseConfig(path.join(widget.packPath, 'config.txt'));
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
                  CupTable(i + 1, cups[i], widget.packPath)
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
          for (var track in widget.cup) CupTableRow(track)
        ]));
  }
}

class CupTableHeader extends StatefulWidget {
  final int cupIndex;
  final String packPath;
  const CupTableHeader(this.cupIndex, this.packPath, {super.key});

  @override
  State<CupTableHeader> createState() => _CupTableHeaderState();
}

class _CupTableHeaderState extends State<CupTableHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.red,
          border:
              Border.all(color: Colors.black, strokeAlign: StrokeAlign.center)),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Track Name",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Center(
                child: Text("track slot",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Center(
                child: Text("music slot",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("File Path",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Image.file(
              File(path.join(
                  widget.packPath, 'Icons', '${widget.cupIndex}.png')),
            )),
          )
        ],
      ),
    );
  }
}

class CupTableRow extends StatefulWidget {
  late Track track;
  CupTableRow(this.track, {super.key});

  @override
  State<CupTableRow> createState() => _CupTableRowState();
}

class _CupTableRowState extends State<CupTableRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amberAccent, border: Border.all(color: Colors.black)),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    widget.track.name,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Center(
                child: Text(
                  widget.track.slotId.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Center(
                child: Text(
                  widget.track.musicId.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    widget.track.path,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Track {
  late String name;
  late int slotId;
  late int musicId;
  late String path;
  Track(this.name, this.slotId, this.musicId, this.path);
  @override
  String toString() {
    return "Track($path)";
  }
}

class AdjustableScrollController extends ScrollController {
  AdjustableScrollController([int extraScrollSpeed = 40]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(super.position.maxScrollExtent,
            max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }
}
