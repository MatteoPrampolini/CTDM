import 'dart:io';

import 'package:ctdm/gui_elements/cup_table.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../gui_elements/types.dart';

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
    Track('Luigi Circuit', 11, 11, 'original file', TrackType.base),
    Track('Moo Moo Meadows', 12, 12, 'original file', TrackType.base),
    Track('Mushroom Gorge', 13, 13, 'original file', TrackType.base),
    Track("Toad's Factory", 14, 14, 'original file', TrackType.base),

    Track('Mario Circuit', 21, 21, 'original file', TrackType.base),
    Track('Coconut Mall', 22, 22, 'original file', TrackType.base),
    Track('DK Summit', 23, 23, 'original file', TrackType.base),
    Track("Wario's Gold Mine", 24, 24, 'original file', TrackType.base),
    //CONTINUA TU
    Track('Daisy Circuit', 31, 31, 'original file', TrackType.base),
    Track('Koopa Cape', 32, 32, 'original file', TrackType.base),
    Track('Maple Treeway', 33, 33, 'original file', TrackType.base),
    Track('Grumble Volcano', 34, 34, 'original file', TrackType.base),
    Track('Dry Dry Ruins', 41, 41, 'original file', TrackType.base),
    Track('Moonview Highway', 42, 42, 'original file', TrackType.base),
    Track("Bowser's Castle", 43, 43, 'original file', TrackType.base),
    Track('Rainbow Road', 44, 44, 'original file', TrackType.base),

    Track('GCN Peach Beach', 51, 51, 'original file', TrackType.base),
    Track('DS Yoshi Falls', 52, 52, 'original file', TrackType.base),
    Track('SNES Ghost Valley 2', 53, 53, 'original file', TrackType.base),
    Track('N64 Mario Raceway', 54, 54, 'original file', TrackType.base),
    Track('N64 Sherbert Land', 61, 61, 'original file', TrackType.base),
    Track('GBA Shy Guy Beach', 62, 62, 'original file', TrackType.base),
    Track('DS Delfino Square', 63, 63, 'original file', TrackType.base),
    Track('GCN Waluigi Stadium', 64, 64, 'original file', TrackType.base),

    Track('DS Desert Hills', 71, 71, 'original file', TrackType.base),
    Track('GBA Bowser Castle 3', 72, 72, 'original file', TrackType.base),
    Track("N64 DK's Jungle Parkway", 73, 73, 'original file', TrackType.base),
    Track('GCN Mario Circuit', 74, 74, 'original file', TrackType.base),
    Track('SNES Mario Circuit 3', 81, 81, 'original file', TrackType.base),
    Track('DS Peach Gardens', 82, 82, 'original file', TrackType.base),
    Track('GCN DK Mountain', 83, 83, 'original file', TrackType.base),
    Track("N64 Bowser's Castle", 84, 84, 'original file', TrackType.base),
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
  List<Cup> cups = [];
  bool keepNintendo = false;
  bool isEditMode = false;
  bool wiimsCup = false;
  final List<Cup> nintendoCups = getNintendoCups();

  @override
  void initState() {
    super.initState();
    createConfigFile(widget.packPath);

    loadMusic(widget.packPath);

    // setState(() {
    //   //parseConfig(path.join(widget.packPath, 'config.txt'));
    //   //print(cups.length);
    // });

    //print(cups);
  }

  void loadMusic(String packPath) {
    File musicTxt = File(path.join(packPath, 'music.txt'));
    if (!musicTxt.existsSync()) return;

    for (String line in musicTxt.readAsLinesSync()) {
      String hex = line.substring(0, 3);
      int i = keepNintendo ? 32 : 0;
      for (Cup cup in cups) {
        // if (i == 32) {
        //   //if in bmg.txt index>32, we are in battle slot. which is not good.
        //   // skip to custom tracks slots at 044 and beyond.
        //   i = 68;
        // }
        for (Track track in cup.tracks) {
          if (i == 32) {
            //if in bmg.txt index>32, we are in battle slot. which is not good.
            // skip to custom tracks slots at 044 and beyond.
            i = 68;
          }

          if (int.parse(hex, radix: 16) == i) {
            track.musicFolder = line.substring(4);
          }

          i++;
        }
      }
    }
  }

  void createConfigFile(String packPath) {
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
    }
    parseConfig(configTxt.path);
  }

  void parseConfig(String configPath) async {
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
        //print(n.submenuIndex);
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
    File configTxt = File(path.join(widget.packPath, 'config.txt'));
    File musicTxt = File(path.join(widget.packPath, 'music.txt'));
    //configTxt.deleteSync();
    //createConfigFile(widget.packPath);

    updateConfigContent(cups, configTxt, keepNintendo, wiimsCup);
    updateMusicConfig(configTxt, musicTxt, keepNintendo);
  }

  void updateMusicConfig(File configTxt, File musicTxt, bool keepNintendo) {
    if (!musicTxt.existsSync()) {
      musicTxt.createSync();
    }

    String content = "";
    int i = keepNintendo ? 32 : 0;

    for (var cup in cups) {
      for (Track track in cup.tracks) {
        if (i == 32) {
          //if in bmg.txt index>32, we are in battle slot. which is not good.
          // skip to custom tracks slots at 044 and beyond.
          i = 68;
        }
        if (track.musicFolder == "..") {
          i++;
          continue;
        }

        if (track.musicFolder != null && track.type != TrackType.menu) {
          content +=
              "${i.toRadixString(16).padLeft(3, '0')};${track.musicFolder!}\n";
        }

        i++;
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

  void setCupsFromAllTracks(List<Track> allTracks) {
    for (Cup cup in cups) {
      cup.tracks.clear();
    }

    int currentTrackIndex = 0;
    for (Cup cup in cups) {
      for (int i = 0; i < 4; i++) {
        if (currentTrackIndex == allTracks.length) {
          break;
        }
        cup.tracks.add(allTracks[currentTrackIndex]);
        if (allTracks[currentTrackIndex].type == TrackType.menu &&
            allTracks[currentTrackIndex + 1].type == TrackType.hidden) {
          i--;
        }
        if (allTracks[currentTrackIndex].type == TrackType.hidden &&
            allTracks[currentTrackIndex + 1].type == TrackType.hidden) {
          i--;
        }
        currentTrackIndex++;
      }
    }

    cups.removeWhere((element) => element.tracks.isEmpty);
  }

  List<Track> sortTracks(List<Track> allTracks) {
    List<Track> sortedTracks = [];

    for (Track track in allTracks) {
      if (track.type == TrackType.hidden) {
        continue;
      }

      if (track.type == TrackType.menu) {
        int insertIndex = sortedTracks.indexWhere((sortedTrack) =>
            sortedTrack.type != TrackType.hidden &&
            track.name.toLowerCase().compareTo(sortedTrack.name.toLowerCase()) <
                0);
        if (insertIndex == -1) {
          sortedTracks.add(track);
        } else {
          sortedTracks.insert(insertIndex, track);
        }

        List<Track> hiddenTracksToAdd = [];
        for (int i = allTracks.indexOf(track) + 1; i < allTracks.length; i++) {
          Track nextTrack = allTracks[i];
          if (nextTrack.type == TrackType.hidden) {
            hiddenTracksToAdd.add(nextTrack);
          } else {
            break;
          }
        }
        sortedTracks.insertAll(
            sortedTracks.indexOf(track) + 1, hiddenTracksToAdd);
      } else {
        int insertIndex = sortedTracks.indexWhere((sortedTrack) =>
            sortedTrack.type != TrackType.hidden &&
            track.name.toLowerCase().compareTo(sortedTrack.name.toLowerCase()) <
                0);
        if (insertIndex == -1) {
          sortedTracks.add(track);
        } else {
          sortedTracks.insert(insertIndex, track);
        }
      }
    }

    return sortedTracks;
  }

  sortCups() {
    List<Track> allTracks = List.empty(growable: true);
    for (var cup in cups) {
      allTracks.addAll(cup.tracks);
    }
    //print(allTracks);
    //allTracks.sort(customSort);
    // cups.forEach((element) {
    //   print(element.tracks);
    // });

    setState(() {
      setCupsFromAllTracks(sortTracks(allTracks));
    });

    // cups.forEach((element) {
    //   print(element.tracks);
    // });
  }

  @override
  Widget build(BuildContext context) {
    //rebuildAllChildren(context);

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
                                      // SizedBox(
                                      //   height: 50,
                                      //   width: 200,
                                      //   child: CheckboxListTile(
                                      //     value: isEditMode,
                                      //     activeColor: Colors.red,
                                      //     title: const Text("Edit Mode"),
                                      //     onChanged: (value) => {
                                      //       keepNintendo = value!,
                                      //       setState(() {})
                                      //     },
                                      //   ),
                                      // ),
                                      SizedBox(
                                          height: 30,
                                          width: 115,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Chiamare la funzione sortAlpha() quando il pulsante viene premuto
                                              //sortAlpha();
                                              sortCups();
                                              setState(() {});
                                            },
                                            style: ElevatedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Colors.white70,
                                                  width: 1.0), // Bordo bianco
                                              // Colore di sfondo del pulsante
                                              elevation:
                                                  2.0, // Elevazione del pulsante
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Icona
                                                SizedBox(
                                                    width:
                                                        8.0), // Spazio tra l'icona e il testo
                                                Text(
                                                  "A-Z Sort", // Testo del pulsante
                                                  style:
                                                      TextStyle(fontSize: 16.0),
                                                ),
                                              ],
                                            ),
                                          )),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            right:
                                                80), // Margine a sinistra di 40 pixel
                                        width:
                                            2, // Larghezza della linea verticale
                                        height:
                                            30, // Altezza desiderata della linea verticale
                                        color: Colors
                                            .grey, // Colore della linea verticale
                                      ),
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
                                            if (wiimsCup) {keepNintendo = true},
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
                                          wiimsCup
                                              ? CupTable(
                                                  9,
                                                  'Wiimms Cup',
                                                  [
                                                    Track(
                                                        'All Tracks',
                                                        0,
                                                        0,
                                                        'Random',
                                                        TrackType.base),
                                                    Track(
                                                        'Original Tracks',
                                                        0,
                                                        0,
                                                        'Random',
                                                        TrackType.base),
                                                    Track(
                                                        "Custom Tracks",
                                                        0,
                                                        0,
                                                        'Random',
                                                        TrackType.base),
                                                    Track(
                                                        'New Tracks',
                                                        0,
                                                        0,
                                                        'Random',
                                                        TrackType.base)
                                                  ],
                                                  widget.packPath,
                                                  9,
                                                  isDisabled: true,
                                                )
                                              : const Text(''),
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
