import 'dart:io';

import 'package:ctdm/custom_drawer.dart';
import 'package:ctdm/drawer_options/cup_icons.dart';
import 'package:ctdm/drawer_options/custom_files.dart';
import 'package:ctdm/patch_window.dart';
import 'package:ctdm/utils/character_utiles.dart';
import 'package:ctdm/utils/excel.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:ctdm/utils/output_utils.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer_options/multiplayer.dart';

class PackEditor extends StatefulWidget {
  final String packPath;
  const PackEditor(this.packPath, {super.key});

  @override
  State<PackEditor> createState() => _PackEditorState();
}

void wipeOldFiles(String packPath) {
  try {
    if (Directory(path.join(packPath, 'Race', 'Course')).existsSync()) {
      Directory(path.join(packPath, 'Race', 'Course'))
          .deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'Race', 'Common')).existsSync()) {
      Directory(path.join(packPath, 'Race', 'Common'))
          .deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'rel')).existsSync()) {
      Directory(path.join(packPath, 'rel')).deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'Scene')).existsSync()) {
      Directory(path.join(packPath, 'Scene')).deleteSync(recursive: true);
    }
    if (Directory(path.join(packPath, 'sys')).existsSync()) {
      Directory(path.join(packPath, 'sys')).deleteSync(recursive: true);
    }
  } catch (_) {
    logString(LogType.ERROR, "cannot create subfolders in $packPath");
  }
}

class _PackEditorState extends State<PackEditor> {
  bool pleaseWait = false;
  bool checkResultVisibility = false;
  bool xmlExist = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canPatch = false;
  bool canRunOnDolphin = false;
  late SharedPreferences prefs;
  List<bool> checks = [false, false, false, false, false, false, false, false];
  final int optIndex = 5;
  final List<String> steps = [
    "valid pack name",
    'track config',
    'lpar config',
    'cup icons',
    'gecko codes',
    'custom characters',
    'custom files',
    'multiplayer'
  ];
  void checkEverything() async {
    checks = [false, false, false, false, false, false, false, false];
    checks[0] = !widget.packPath.contains('tmp_pack_');
    checks[1] = File(path.join(widget.packPath, 'config.txt')).existsSync();
    checks[2] = File(path.join(widget.packPath, 'lpar.txt')).existsSync();

    if (!Directory(path.join(widget.packPath, 'Icons')).existsSync()) {
      checks[3] = false;
    } else {
      if (File(path.join(widget.packPath, 'Icons', 'merged.png'))
          .existsSync()) {
        File(path.join(widget.packPath, 'Icons', 'merged.png')).deleteSync();
      }
      checks[3] = Directory(path.join(widget.packPath, 'Icons'))
                  .listSync()
                  .whereType<File>()
                  .toList()
                  .length -
              2 ==
          getNumberOfIconsFromConfig(widget.packPath);
    }
    if (!widget.packPath.contains("tmp_pack_")) {
      checks[4] = File(path.join(widget.packPath, 'gecko.txt')).existsSync();
      // checks[4] = parseGeckoTxt(
      //         widget.packPath, File(path.join(widget.packPath, 'gecko.txt')))
      //     .isNotEmpty;
    }

    if (getNumberOfCustomCharacters(
            File(path.join(widget.packPath, 'characters.txt'))) >
        0) {
      checks[5] = true;
    }

    checks[6] = getNofCustomUiSelected(widget.packPath) > 0 ||
        getNofMiscFiles(widget.packPath) > 0;

    String regionContent = readRegionFile(widget.packPath);
    if (regionContent != "") {
      checks[7] = regionContent.split(";").last == "true";
    }

    canPatch = checks.take(optIndex).every((element) => element == true);
    // if (!checkResultVisibility && !canPatch) {
    //   checkResultVisibility = true;
    //   Future.delayed(const Duration(seconds: 5), () {
    //     //asynchronous delay
    //     if (mounted) {
    //       //checks if widget is still active and not disposed
    //       //tells the widget builder to rebuild again because ui has updated
    //       setState(() => checkResultVisibility = false);
    //     }
    //   });
    // }
    canRunOnDolphin = await File(path.join(
            widget.packPath, "${path.basename(widget.packPath)}.json"))
        .exists();
    setState(() {});
  }

  @override
  void initState() {
    loadSettings();

    List tmp = Directory(widget.packPath).listSync().whereType<File>().toList();
    tmp.retainWhere((element) => element.path.endsWith('xml'));

    xmlExist = tmp.isNotEmpty;
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      checkEverything();
    });
  }

  void loadSettings() async {
    if (!Directory(path.join(widget.packPath, "..", "..", 'myCodes'))
        .existsSync()) {
      Directory(path.join(widget.packPath, "..", "..", 'myCodes')).createSync();
      //copyGeckoAssetsToPack(widget.packPath);
    }

    if (!await Directory(path.join(widget.packPath, 'Scene')).exists()) {
      Directory(path.join(widget.packPath, 'Scene')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Scene', 'UI')).exists()) {
      Directory(path.join(widget.packPath, 'Scene', 'UI')).create();
    }
    // if (!await Directory(path.join(widget.packPath, 'Scene', 'Model'))
    //     .exists()) {
    //   Directory(path.join(widget.packPath, 'Scene', 'UI', 'Model')).create();
    // }
    if (!await Directory(path.join(widget.packPath, 'sys')).exists()) {
      Directory(path.join(widget.packPath, 'sys')).create();
      if (!await Directory(path.join(widget.packPath, 'sys')).exists()) {
        Directory(path.join(widget.packPath, 'sys')).create();
      }
    }
    if (!await Directory(path.join(widget.packPath, 'rel')).exists()) {
      Directory(path.join(widget.packPath, 'rel')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race')).exists()) {
      Directory(path.join(widget.packPath, 'Race')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race', 'Course'))
        .exists()) {
      Directory(path.join(widget.packPath, 'Race', 'Course')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race', 'Common'))
        .exists()) {
      Directory(path.join(widget.packPath, 'Race', 'Common')).create();
    }
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool checkEverythingAfterNotification(DrawerOnExit n) {
    checkEverything();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NotificationListener<DrawerOnExit>(
          onNotification: checkEverythingAfterNotification,
          child: CustomDrawer(widget.packPath, xmlExist)),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.red.shade700, //change your color here
        ),
        backgroundColor: Colors.amber,
        title: Text(
          'Pack Editor ${path.basename(widget.packPath)}',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: pleaseWait == false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Automatic Check List",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.fontSize)),
                        SizedBox(
                          height: steps.length * 45 + 20,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ListView.builder(
                              itemCount: steps.length,
                              itemBuilder: (context, index) {
                                var step = steps[index];
                                return SizedBox(
                                  height: 45,
                                  width: 300,
                                  child: ListTile(
                                    onTap: null,
                                    enabled: checks[index],
                                    title: Text(step),
                                    trailing: index >= optIndex
                                        ? const Text(
                                            "[opt]",
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : null,
                                    leading: Checkbox(
                                      splashRadius: 0,
                                      value: checks[index],
                                      //activeColor: Colors.amberAccent,

                                      fillColor: checks[index]
                                          ? MaterialStateProperty.all(
                                              Colors.amberAccent)
                                          : MaterialStateProperty.all(
                                              Colors.transparent),

                                      side: const BorderSide(
                                          color: Colors.white38, width: 2),
                                      onChanged: null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                Colors.red)),
                                    onPressed: () => {
                                          checkResultVisibility = true,
                                          //_scaffoldKey.currentState?.openDrawer(),
                                          checkEverything(),

                                          if (!canPatch)
                                            {
                                              Future.delayed(
                                                  const Duration(seconds: 2),
                                                  () {
                                                checkResultVisibility = false;
                                                //asynchronous delay
                                                if (mounted) {
                                                  //checks if widget is still active and not disposed
                                                  //tells the widget builder to rebuild again because ui has updated
                                                  _scaffoldKey.currentState
                                                      ?.openDrawer();
                                                }
                                              })
                                            }
                                        },
                                    child: const Text(
                                      "CHECK",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amberAccent),
                                    onPressed: canPatch
                                        ? () => {
                                              wipeOldFiles(widget.packPath),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PatchWindow(
                                                              widget.packPath)))
                                            }
                                        : null,
                                    child: Text("PATCH!",
                                        style: TextStyle(
                                            color: canPatch
                                                ? Colors.black
                                                : Colors.white)),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: () => {
                                          exportToExcel(
                                              widget.packPath, context)
                                        },
                                    child: const Text(
                                      "EXPORT XLSX",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amberAccent),
                                    onPressed: canPatch
                                        ? () => {
                                              wipeOldFiles(widget.packPath),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PatchWindow(
                                                            widget.packPath,
                                                            fastPatch: true,
                                                          )))
                                            }
                                        : null,
                                    child: Text("NO MUSIC PATCH!",
                                        style: TextStyle(
                                            color: canPatch
                                                ? Colors.black
                                                : Colors.white)),
                                  )),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: canRunOnDolphin,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 8, right: 8),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      onPressed: canRunOnDolphin
                                          ? () async => {
                                                setState(
                                                    () => pleaseWait = true),
                                                await zipPack(
                                                    [widget.packPath]),
                                                setState(
                                                    () => pleaseWait = false),
                                              }
                                          : null,
                                      child: const Text("EXPORT ZIP",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    )),
                              ),
                              Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.5, left: 8, right: 8),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.lightBlueAccent),
                                        onPressed: canRunOnDolphin
                                            ? () => {
                                                  runOnDolphin([
                                                    prefs.getString('dolphin')!,
                                                    path.join(widget.packPath,
                                                        "${path.basename(widget.packPath)}.json"),
                                                    widget.packPath,
                                                    prefs.getString('game')!
                                                  ])
                                                }
                                            : null,
                                        child: const Text(
                                          "RUN ON DOLPHIN",
                                          style:
                                              TextStyle(color: Colors.black87),
                                        ))),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Visibility(
                              visible: checkResultVisibility,
                              child: Text(
                                canPatch
                                    ? "You can patch."
                                    : "Missing mandatory steps.",
                                style: const TextStyle(color: Colors.white60),
                              )),
                        )
                      ],
                    )
                  : const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Compressing your CT Distribution...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.amber,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Do not exit this page.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          )),
    );
  }
}

void showResultModal(BuildContext context, String title, String result) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(color: Colors.amberAccent),
        ),
        content:
            FittedBox(fit: BoxFit.fitWidth, child: Text(result, maxLines: 2)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
