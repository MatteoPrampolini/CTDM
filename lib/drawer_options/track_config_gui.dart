import 'dart:io';

import 'package:ctdm/gui_elements/cup_table.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../gui_elements/types.dart';

void createConfigFile(String packPath) {
  if (!File(path.join(packPath, 'config.txt')).existsSync()) {
    File configFile = File("assets/config.txt");
    configFile.copySync(path.join(packPath, 'config.txt'));
  }
}

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
    createConfigFile(widget.packPath);
    setState(() {
      cups = parseConfig(path.join(widget.packPath, 'config.txt'));
      //print(cups.length);
    });

    print(cups);
  }

  void deleteRow(int cupIndex, int rowIndex) {
    // print("search");
    cups[cupIndex - 1].removeAt(rowIndex - 1);
    setState(() {
      // if (cups[cupIndex - 1].length < rowIndex) {
      //   print("c'è un problema");
      //   //print(rowIndex);
      //   return;
      // }
      //cups[cupIndex - 1].removeAt(rowIndex - 1);
    });
    print(cups[cupIndex - 1]);
  }

  bool rowAskedForDeletionNotification(RowDeletePressed n) {
    //print(this.widget.cup);

    //print("devo eliminare track ${n.rowIndex} in cup ${n.cupIndex}");
    deleteRow(n.cupIndex, n.rowIndex);
    //print(cups[n.cupIndex - 1]);
    return true;
  }

  bool addEmptyRow(AddTrackRequest n) {
    //print(n.cupIndex);
    setState(() {
      if (n.lastHiddenIndex == null) {
        cups[n.cupIndex - 1]
            .add(Track('', 11, 11, "-----ADD TRACK-----", n.type));
      } else {
        //print("lastHidden:${n.lastHiddenIndex}");
        cups[n.cupIndex - 1].insert(n.lastHiddenIndex!,
            Track('', 11, 11, "-----ADD TRACK-----", n.type));
      }
    });
    print(cups[n.cupIndex - 1]);
    return true;
  }

  bool changeDeleteMode(DeleteModeUpdated n) {
    //print(n.shouldDelete);
    return true;
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track config GUI",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: AdjustableScrollController(80),
              child: NotificationListener<AddTrackRequest>(
                onNotification: addEmptyRow,
                child: NotificationListener<RowDeletePressed>(
                  onNotification: rowAskedForDeletionNotification,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < cups.length; i++)
                          CupTable(i + 1, cups[i], widget.packPath),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 2 - 100,
                              right:
                                  MediaQuery.of(context).size.width / 2 - 100,
                              bottom: 60),
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton(
                              child: const Text("Add cup"),
                              onPressed: () => {
                                setState(() => {cups.add([])})
                              },
                            ),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ],
        ));
  }
}
