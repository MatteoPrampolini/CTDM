import 'dart:io';

import 'package:ctdm/gui_elements/cup_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import '../gui_elements/types.dart';

Future<String> loadAsset(String assetPath) async {
  return await rootBundle.loadString(assetPath);
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
      //parseConfig(path.join(widget.packPath, 'config.txt'));
      //print(cups.length);
    });

    //print(cups);
  }

  void createConfigFile(String packPath) async {
    File configTxt = File(path.join(packPath, 'config.txt'));
    if (!configTxt.existsSync()) {
      configTxt.createSync();

      configTxt.writeAsStringSync(await loadAsset("assets/config.txt"),
          flush: true);

      parseConfig(configTxt.path);
      return;
      // //print(await loadAsset("assets/config.txt"));
      // //loadAsset("assets/config.txt").then((value) => print("ciao"));
    }
    parseConfig(configTxt.path);
  }

  parseConfig(String configPath) {
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
    this.cups = cups;
  }

  void deleteRow(int cupIndex, int rowIndex) {
    cups[cupIndex - 1].removeAt(rowIndex - 1);
    setState(() {});
  }

  bool rowAskedForDeletionNotification(RowDeletePressed n) {
    deleteRow(n.cupIndex, n.rowIndex);
    return true;
  }

  bool rowChangedValue(RowChangedValue n) {
    cups[n.cupIndex - 1][n.rowIndex - 1] = n.track;
    //TODO MUSIC FOLDER
    print(cups[n.cupIndex - 1][n.rowIndex - 1]);
    return true;
  }

  bool addEmptyRow(AddTrackRequest n) {
    //print(n.cupIndex);
    setState(() {
      if (n.lastHiddenIndex == null) {
        if (n.type == TrackType.base) {
          cups[n.cupIndex - 1]
              .add(Track('', 11, 11, "-----ADD TRACK-----", n.type));
        }
        if (n.type == TrackType.menu) {
          cups[n.cupIndex - 1].add(Track('', 11, 11, "temp", n.type));
        }
      } else {
        //print("lastHidden:${n.lastHiddenIndex}");
        cups[n.cupIndex - 1].insert(n.lastHiddenIndex!,
            Track('', 11, 11, "-----ADD TRACK-----", n.type));
      }
    });
    //print(cups[n.cupIndex - 1]);
    return true;
  }

  bool deleteHeaderPressed(DeleteModeUpdated n) {
    if (n.destroyCupIndex! > 0 &&
        cups[n.destroyCupIndex! - 1].isEmpty &&
        n.shouldDelete == true) {
      cups.removeAt(n.destroyCupIndex! - 1);
    }
    setState(() {});
    return true;
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void saveConfig() {
    //print(cups);
    // if (cups.length < 4) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: const Text(r'Not valid config.'),
    //       content: SingleChildScrollView(
    //         child: ListBody(
    //           children: <Widget>[
    //             Text(
    //                 'you made ${cups.length} cups but the required minimum is 4.'),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: const Text('OK'),
    //           onPressed: () {
    //             Get.back();
    //             //Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }
    // if (cups.any((element) =>
    //     element.where((element2) => element2.type != TrackType.hidden).length <
    //     4)) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: const Text(r'Not valid config.'),
    //       content: SingleChildScrollView(
    //         child: ListBody(
    //           children: const <Widget>[
    //             Text('All the cups must have at least 4 selactable tracks.'),
    //           ],
    //         ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: const Text('OK'),
    //           onPressed: () {
    //             Get.back();
    //             //Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    //   return;
    // }
    File configTxt = File(path.join(widget.packPath, 'config.txt'));
    //configTxt.deleteSync();
    //createConfigFile(widget.packPath);

    appendToFreshConfig(cups, configTxt);
  }

  appendToFreshConfig(List<List<Track>> cups, File configTxt) {
    String content = r"""#CT-CODE

[RACING-TRACK-LIST]

# enable support for LE-CODE flags
%LE-FLAGS  = 1

# auto insert a Wiimm cup (4 special random slots)
%WIIMM-CUP = 0

# standard setup
N N$NONE | N$F_WII

""";
    int i = 1;
    for (var cup in cups) {
      content = "${content}C $i\n";
      i++;
      for (var track in cup) {
        content = content + trackToString(track);
      }
      content = "$content\n";
    }
    configTxt.writeAsStringSync(content, mode: FileMode.write);
    print(content);
  }

  String trackToString(Track track) {
    String typeLetter = "";
    String code = "";
    switch (track.type) {
      case TrackType.base:
        typeLetter = "T";
        code = "0x00";

        break;
      case TrackType.menu:
        typeLetter = "T";
        code = "0x02";

        break;
      case TrackType.hidden:
        typeLetter = "H";
        code = "0x04";

        break;
    }
    return '$typeLetter T${track.musicId}; T${track.slotId}; $code; "${track.path}"; "${track.name}";\n';
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    print(cups);
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
              child: NotificationListener<RowChangedValue>(
                onNotification: rowChangedValue,
                child: NotificationListener<DeleteModeUpdated>(
                  onNotification: deleteHeaderPressed,
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
                                  left: MediaQuery.of(context).size.width / 2 -
                                      140,
                                  right: MediaQuery.of(context).size.width / 2 -
                                      140,
                                  bottom: 60),
                              child: SizedBox(
                                height: 60,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      child: const Text("Add cup"),
                                      onPressed: () => {
                                        setState(() => {cups.add([])})
                                      },
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: ElevatedButton(
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.amberAccent)),
                                          child: const Text(
                                            "Save config",
                                            style: TextStyle(
                                                color: Colors.black87),
                                          ),
                                          onPressed: () => {saveConfig()},
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
