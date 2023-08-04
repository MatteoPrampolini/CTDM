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

List<Cup> getNintendoCups() {
  List<Cup> nintendo = [];
  List<Track> trackList = [
    Track('Luigi Circuit', 11, 11, '--', TrackType.base),
    Track('Moo Moo Meadows', 12, 12, '--', TrackType.base),
    Track('Mushroom Gorge', 13, 13, '--', TrackType.base),
    Track("Toad's Factory", 14, 14, '--', TrackType.base),

    Track('Mario Circuit', 21, 21, '--', TrackType.base),
    Track('Coconut Mall', 22, 22, '--', TrackType.base),
    Track('DK Summit', 23, 23, '--', TrackType.base),
    Track("Wario's Gold Mine", 24, 24, '--', TrackType.base),
    //CONTINUA TU
    Track('Daisy Circuit', 31, 31, '--', TrackType.base),
    Track('Koopa Cape', 32, 32, '--', TrackType.base),
    Track('Maple Treeway', 33, 33, '--', TrackType.base),
    Track('Grumble Volcano', 34, 34, '--', TrackType.base),
    Track('Dry Dry Ruins', 41, 41, '--', TrackType.base),
    Track('Moonview Highway', 42, 42, '--', TrackType.base),
    Track("Bowser's Castle", 43, 43, '--', TrackType.base),
    Track('Rainbow Road', 44, 44, '--', TrackType.base),

    Track('GCN Peach Beach', 51, 51, '--', TrackType.base),
    Track('DS Yoshi Falls', 52, 52, '--', TrackType.base),
    Track('SNES Ghost Valley 2', 53, 53, '--', TrackType.base),
    Track('N64 Mario Raceway', 54, 54, '--', TrackType.base),
    Track('N64 Sherbert Land', 61, 61, '--', TrackType.base),
    Track('GBA Shy Guy Beach', 62, 62, '--', TrackType.base),
    Track('DS Delfino Square', 63, 63, '--', TrackType.base),
    Track('GCN Waluigi Stadium', 64, 64, '--', TrackType.base),

    Track('DS Desert Hills', 71, 71, '--', TrackType.base),
    Track('GBA Bowser Castle 3', 72, 72, '--', TrackType.base),
    Track("N64 DK's Jungle Parkway", 73, 73, '--', TrackType.base),
    Track('GCN Mario Circuit', 74, 74, '--', TrackType.base),
    Track('SNES Mario Circuit 3', 81, 81, '--', TrackType.base),
    Track('DS Peach Gardens', 82, 82, '--', TrackType.base),
    Track('GCN DK Mountain', 83, 83, '--', TrackType.base),
    Track("N64 Bowser's Castle", 84, 84, '--', TrackType.base),
  ];
  nintendo.add(Cup('Mushroom Cup', trackList.getRange(0, 4).toList()));
  nintendo.add(Cup('Shell Cup', trackList.getRange(4 * 4, (4 * 5)).toList()));
  nintendo.add(Cup('Flower Cup', trackList.getRange(4 * 1, (4 * 2)).toList()));
  nintendo.add(Cup('Banana Cup', trackList.getRange(4 * 5, (4 * 6)).toList()));
  nintendo.add(Cup('Star Cup', trackList.getRange(4 * 2, (4 * 3)).toList()));
  nintendo.add(Cup('Leaf Cup', trackList.getRange(4 * 6, (4 * 7)).toList()));
  nintendo.add(Cup('Special Cup', trackList.getRange(4 * 3, (4 * 4)).toList()));
  nintendo
      .add(Cup('Lightning Cup', trackList.getRange(4 * 7, (4 * 8)).toList()));

  return nintendo;
}

class TrackConfigGui extends StatefulWidget {
  final String packPath;
  const TrackConfigGui(this.packPath, {super.key});

  @override
  State<TrackConfigGui> createState() => _TrackConfigGuiState();
}

class _TrackConfigGuiState extends State<TrackConfigGui> {
  //late List<List<Track>> cups = [];
  late List<Cup> cups = [];
  bool keepNintendo = false;
  bool wiimsCup = false;
  late List<Cup> nintendoCups;

  @override
  void initState() {
    super.initState();
    createConfigFile(widget.packPath);
    loadMusic(widget.packPath);

    nintendoCups = getNintendoCups();
    setState(() {
      //parseConfig(path.join(widget.packPath, 'config.txt'));
      //print(cups.length);
    });

    //print(cups);
  }

  void loadMusic(String packPath) {
    File musicTxt = File(path.join(packPath, 'music.txt'));
    if (!musicTxt.existsSync()) return;

    for (String line in musicTxt.readAsLinesSync()) {
      String hex = line.substring(0, 3);
      int i = 0;
      for (Cup cup in cups) {
        for (Track track in cup.tracks) {
          if (int.parse(hex, radix: 16) == i) {
            track.musicFolder = line.substring(4);
          }

          i++;
          if (i == 32) {
            //if in bmg.txt index>32, we are in battle slot. which is not good.
            // skip to custom tracks slots at 044 and beyond.
            i = 68;
          }
        }
      }
    }
  }

  void createConfigFile(String packPath) async {
    File configTxt = File(path.join(packPath, 'config.txt'));
    if (!configTxt.existsSync()) {
      String assetConfigPath = path.join(
          path.dirname(Platform.resolvedExecutable),
          "data",
          "flutter_assets",
          "assets",
          "config.txt");

      File(assetConfigPath).copySync(path.join(packPath, 'config.txt'));

      parseConfig(configTxt.path);
      return;
      // //print(await loadAsset("assets/config.txt"));
      // //loadAsset("assets/config.txt").then((value) => print("ciao"));
    }
    parseConfig(configTxt.path);
  }

  void parseConfig(String configPath) {
    //List<List<Track>> cups = [];
    List<Cup> cups = [];
    File configFile = File(configPath);
    String contents = configFile.readAsStringSync();
    keepNintendo = false;
    wiimsCup = false;
    if (contents.contains(r'N$SWAP')) {
      keepNintendo = true;
    }
    if (contents.contains(r'%WIIMM-CUP = 1')) {
      wiimsCup = true;
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
    this.cups = cups;
  }

  void deleteRow(int cupIndex, int rowIndex) {
    cups[cupIndex - 1].tracks.removeAt(rowIndex - 1);
    setState(() {});
  }

  bool rowAskedForDeletionNotification(RowDeletePressed n) {
    int nChildren = 1;
    if (n.nChildren == null) {
      nChildren = 1;
    } else {
      nChildren = n.nChildren!;
    }
    for (int i = 0; i < nChildren; i++) {
      deleteRow(n.cupIndex, n.rowIndex);
    }
    return true;
  }

  bool updateCupName(CupNameChangedValue n) {
    cups[n.cupIndex - 1].cupName = r'"' + n.cupName.replaceAll(r'"', '') + r'"';
    return true;
  }

  bool rowChangedValue(RowChangedValue n) {
    cups[n.cupIndex - 1].tracks[n.rowIndex - 1] = n.track;
    return true;
  }

  bool addEmptyRow(AddTrackRequest n) {
    //print(n.cupIndex);

    setState(() {
      if (n.submenuIndex == null) {
        if (n.type == TrackType.base) {
          cups[n.cupIndex - 1]
              .tracks
              .add(Track('', 11, 11, "-----ADD TRACK-----", n.type));
        }
        if (n.type == TrackType.menu) {
          cups[n.cupIndex - 1].tracks.add(Track('', 11, 11, "temp", n.type));
        }
        //if i have to insert a basetrack inside a specific submenu
      } else {
        //print("lastHidden:${n.lastHiddenIndex}");
        int rightPlace = n.submenuIndex!;

        cups[n.cupIndex - 1].tracks.insert(
            rightPlace, Track('', 11, 11, "-----ADD TRACK-----", n.type));
      }
    });
    //print(cups[n.cupIndex - 1]);
    return true;
  }

  bool deleteHeaderPressed(DeleteModeUpdated n) {
    if (n.destroyCupIndex! > 0 &&
        cups[n.destroyCupIndex! - 1].tracks.isEmpty &&
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
    File musicTxt = File(path.join(widget.packPath, 'music.txt'));
    //configTxt.deleteSync();
    //createConfigFile(widget.packPath);

    updateConfigContent(cups, configTxt, keepNintendo, wiimsCup);
    updateMusicConfig(configTxt, musicTxt);
  }

  void updateMusicConfig(File configTxt, File musicTxt) {
    if (!musicTxt.existsSync()) {
      musicTxt.createSync();
    }
    String content = "";
    int i = 0;
    for (var cup in cups) {
      for (Track track in cup.tracks) {
        if (track.musicFolder != null && track.type != TrackType.menu) {
          content +=
              "${i.toRadixString(16).padLeft(3, '0')};${track.musicFolder!}\n";
        }
        i++;
        if (i == 32) {
          //if in bmg.txt index>32, we are in battle slot. which is not good.
          // skip to custom tracks slots at 044 and beyond.
          i = 68;
        }
      }
    }
    musicTxt.writeAsStringSync(content, mode: FileMode.write);
  }

  void updateConfigContent(
      List<Cup> cups, File configTxt, bool useNintendoTracks, bool wiimmCup) {
    String wiimmString = '0';
    String nintendoTracksString = r'$NONE';

    if (wiimmCup == true) {
      wiimmString = '1';
    }
    if (useNintendoTracks == true) {
      nintendoTracksString = r'$SWAP';
    }
    String content = """#CT-CODE

[RACING-TRACK-LIST]

# enable support for LE-CODE flags
%LE-FLAGS  = 1

# auto insert a Wiimm cup (4 special random slots)
%WIIMM-CUP = $wiimmString

# standard setup
N N$nintendoTracksString | """
        r'N$F_WII'
        '\n\n';

    for (var cup in cups) {
      content = "${content}C ${cup.cupName}\n";

      for (var track in cup.tracks) {
        content = content + trackToString(track);
      }
      content = "$content\n";
    }
    configTxt.writeAsStringSync(content, mode: FileMode.write);
    //print(content);
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
                    child: NotificationListener<CupNameChangedValue>(
                      onNotification: updateCupName,
                      child: NotificationListener<RowDeletePressed>(
                        onNotification: rowAskedForDeletionNotification,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, right: 100),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 280,
                                        child: CheckboxListTile(
                                          value: keepNintendo,
                                          activeColor: Colors.red,
                                          title: const Text(
                                              "Keep Nintendo tracks"),
                                          onChanged: (value) => {
                                            keepNintendo = value!,
                                            setState(() {})
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width: 200,
                                        child: CheckboxListTile(
                                          value: wiimsCup,
                                          activeColor: Colors.red,
                                          title: const Text("Wiimm's cup"),
                                          onChanged: (value) => {
                                            wiimsCup = value!,
                                            keepNintendo = value,
                                            setState(() {})
                                          },
                                        ),
                                      ),
                                    ]),
                              ),
                              const Divider(),
                              keepNintendo
                                  ? IgnorePointer(
                                      ignoring: true,
                                      child: Column(
                                        children: [
                                          for (int i = 0;
                                              i < nintendoCups.length;
                                              i++)
                                            CupTable(
                                                i + 1,
                                                nintendoCups[i].cupName,
                                                nintendoCups[i].tracks,
                                                widget.packPath,
                                                i + 1,
                                                isDisabled: true),
                                        ],
                                      ),
                                    )
                                  : const Text(''),
                              for (int i = 0; i < cups.length; i++)
                                CupTable(
                                  i + 1,
                                  cups[i].cupName,
                                  cups[i].tracks,
                                  widget.packPath,
                                  keepNintendo
                                      ? i + 9 + (wiimsCup ? 1 : 0)
                                      : i + 1,
                                ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        MediaQuery.of(context).size.width / 2 -
                                            140,
                                    right:
                                        MediaQuery.of(context).size.width / 2 -
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
                                          setState(() => cups.add(Cup(
                                              '"Cup #${cups.length + 1}"', [])))
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
                                            onPressed: () => {
                                              saveConfig(),
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    });
                                                    return const AlertDialog(
                                                      content: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text("Saved"),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8.0),
                                                            child: Icon(
                                                                Icons.thumb_up),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  })
                                            },
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
            ),
          ],
        ));
  }
}
