import 'dart:convert';
import 'dart:io';
import 'package:ctdm/utils/filepath_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

enum Scene {
  award,
  channel,
  event,
  globe,
  menuMulti,
  menuOther,
  menuSingle,
  present,
  race,
  title
}

enum SceneComplete {
  award,
  award_,
  channel,
  channel_,
  event,
  event_,
  globe,
  globe_,
  menuMulti,
  menuMulti_,
  menuOther,
  menuOther_,
  menuSingle,
  menuSingle_,
  present,
  present_,
  race,
  race_,
  title,
  title_
}

int getNofCustomUiSelected(String packPath) {
  File uiFile = File(path.join(packPath, 'ui.txt'));
  if (!uiFile.existsSync()) {
    return 0;
  }
  List<String> a = uiFile
      .readAsStringSync()
      .replaceAll(RegExp(r'[\[\]]'), '')
      .trim()
      .split(',')
      .toList();
  return a.where((element) => element.toLowerCase() == "true").length;
}

int getNofMiscFiles(String packPath) {
  File miscFile = File(path.join(packPath, 'misc.txt'));
  if (!miscFile.existsSync()) {
    return 0;
  }
  return miscFile.readAsLinesSync().length;
}

void saveUIConfig(File uiFile, List<bool> values) {
  uiFile.writeAsStringSync(jsonEncode(values));
}

List<bool> loadUIconfig(String packPath) {
  List<bool> values =
      List.generate(Scene.values.length * 2, (index) => false, growable: false);
  File uiFile = File(path.join(packPath, 'ui.txt'));
  if (!uiFile.existsSync()) {
    uiFile.createSync();
    saveUIConfig(uiFile, values);
    return values;
  }

  List<String> a = uiFile
      .readAsStringSync()
      .replaceAll(RegExp(r'[\[\]]'), '')
      .trim()
      .split(',')
      .toList();

  return a.map((string) => string.toLowerCase() == "true").toList();
}

File getFileFromIndex(String packPath, int index) {
  String originalDiscPath = getOriginalDiscPath(packPath);
  String filePath = '';
  if (index % 2 == 0) {
    //from ORIGINAL_DISC
    String basename =
        '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}.szs';
    filePath = path.join(originalDiscPath, 'files', 'Scene', 'UI', basename);
  } else {
    //from assets
    String basename =
        '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}_U.szs';

    filePath = path.join(path.dirname(Platform.resolvedExecutable), "data",
        "flutter_assets", "assets", "scene", basename);
  }

  return File(filePath);
}

List<MiscItem> getListOfMisc() {
  List<MiscItem> miscList = [];
  miscList.add(MiscItem('Common', path.join('Race', 'Common.szs'), false));
  miscList.add(MiscItem('Font', path.join('Scene', 'UI', 'Font.szs'), false));
  miscList
      .add(MiscItem('revo_kart', path.join('sound', 'revo_kart.brsar'), false));
  return miscList;
}

List<MiscItem> readMiscTxt(List<MiscItem> miscList, File misc) {
  List<String> lines = misc.readAsLinesSync();
  for (String line in lines) {
    if (miscList.any((e) => line.contains(e.name))) {
      miscList
          .elementAt(miscList.indexWhere((element) => element.name == line))
          .selected = true;
    }
  }

  return miscList;
}

void saveMiscFile(File miscTxt, List<MiscItem> miscList) {
  String contents = "";
  for (MiscItem miscItem in miscList.where((element) => element.selected)) {
    contents += "$miscItem\n";
  }
  miscTxt.writeAsStringSync(contents, mode: FileMode.write);
}

class CustomUI extends StatefulWidget {
  final String packPath;
  const CustomUI(this.packPath, {super.key});

  @override
  State<CustomUI> createState() => _CustomUIState();
}

class _CustomUIState extends State<CustomUI> {
  late List<bool> values;
  List<MiscItem> miscList = getListOfMisc();
  late File miscTxt = File(path.join(widget.packPath, 'misc.txt'));
  @override
  void initState() {
    values = loadUIconfig(widget.packPath);
    if (!miscTxt.existsSync()) {
      saveMiscFile(miscTxt, miscList);
    } else {
      miscList = readMiscTxt(miscList, miscTxt);
    }
    super.initState();
    createFilesUi();
    createFilesMisc(miscList);
  }

  Future<void> createFilesUi() async {
    if (!await Directory(path.join(widget.packPath, 'myUI')).exists()) {
      await Directory(path.join(widget.packPath, 'myUI')).create();
    }
    for (int i = 0; i < values.length; i++) {
      if (values[i] == false) continue;
      File tmpFile = getFileFromIndex(widget.packPath, i);
      if (!await File(
              path.join(widget.packPath, 'myUI', path.basename(tmpFile.path)))
          .exists()) {
        tmpFile.copy(
            path.join(widget.packPath, 'myUI', path.basename(tmpFile.path)));
      }
    }
  }

  Future<void> createFilesMisc(List<MiscItem> miscList) async {
    if (!await Directory(path.join(widget.packPath, 'misc')).exists()) {
      await Directory(path.join(widget.packPath, 'misc')).create();
    }

    for (MiscItem miscItem in miscList.where((element) => element.selected)) {
      if (await File(
              path.join(widget.packPath, 'misc', path.basename(miscItem.path)))
          .exists()) {
        continue;
      }
      await File(path.join(
              getOriginalDiscPath(widget.packPath), 'files', miscItem.path))
          .copy(
              path.join(widget.packPath, 'misc', path.basename(miscItem.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Custom Files",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.red.shade700),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                const Text(
                  "Select which files you want to replace",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 20),
                      child: Text(
                        "Scenes",
                        style: TextStyle(color: Colors.white70, fontSize: 35),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsetsDirectional.all(40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: Scene.values.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: (1 / 0.8),
                      maxCrossAxisExtent: 220,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54)),
                        child: Column(children: [
                          Text(
                            Scene.values.elementAt(index).name.toCapitalized(),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.redAccent),
                          ),
                          CheckboxListTile(
                              activeColor: Colors.red,
                              checkColor: Colors.white,
                              title: FittedBox(
                                child: Text(
                                  "${Scene.values.elementAt(index).name.toCapitalized()}.szs",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  values[index * 2] = value!;
                                  saveUIConfig(
                                      File(
                                          path.join(widget.packPath, 'ui.txt')),
                                      values);
                                });
                              },
                              value: values[index * 2]),
                          CheckboxListTile(
                              activeColor: Colors.red,
                              checkColor: Colors.white,
                              title: FittedBox(
                                child: Text(
                                  "${Scene.values.elementAt(index).name.toCapitalized()}_U.szs",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  values[(index * 2) + 1] = value!;
                                  saveUIConfig(
                                      File(
                                          path.join(widget.packPath, 'ui.txt')),
                                      values);
                                });
                              },
                              value: values[(index * 2) + 1])
                        ]),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 20),
                      child: Text(
                        "Miscellaneous",
                        style: TextStyle(color: Colors.white70, fontSize: 35),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsetsDirectional.all(40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: miscList.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: (1 / 0.42),
                      maxCrossAxisExtent: 220,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54)),
                        child: Column(children: [
                          Text(
                            miscList[index].name,
                            style: const TextStyle(
                                fontSize: 19, color: Colors.redAccent),
                          ),
                          CheckboxListTile(
                              checkColor: Colors.white,
                              activeColor: Colors.red,
                              title: FittedBox(
                                child: Text(
                                  path.basename(miscList[index].path),
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  miscList[index].selected = value!;
                                  saveMiscFile(miscTxt, miscList);
                                });
                              },
                              value: miscList[index].selected),
                        ]),
                      );
                    },
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 + 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text("Create files",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white)),
                            onPressed: () async =>
                                {createFilesUi(), createFilesMisc(miscList)}),
                        ElevatedButton(
                          style:
                              TextButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Open folder",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)),
                          onPressed: () async => {
                            if (!Directory(path.join(widget.packPath, 'myUI'))
                                .existsSync())
                              {
                                Directory(path.join(widget.packPath, 'myUI'))
                                    .createSync()
                              }
                            else
                              1 + 1, //added to avoid compiler error
                            if (!Platform.isLinux)
                              {
                                launchUrlString(
                                    path.join(widget.packPath, 'myUI'))
                              }
                            else if (Platform.isLinux)
                              {
                                await Process.start('xdg-open',
                                    [path.join(widget.packPath, 'myUI')]),

                                //await
                              }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            )),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String createXmlStringForUi(
    String packPath, List<bool> filesBool, List<File> sceneFiles) {
  String contents = "\t\t<!--CUSTOM UI-->\n";
  String packName = path.basename(packPath);
  for (int i = 0; i < SceneComplete.values.length; i++) {
    if (i == SceneComplete.menuSingle.index ||
        i == SceneComplete.menuSingle_.index) {
      continue;
    }
    if (i == SceneComplete.race_.index || i == SceneComplete.race_.index) {
      continue;
    }
    String basename = path.basename(getFileFromIndex(packPath, i).path);
    if (!sceneFiles.any((element) => path.basename(element.path) == basename)) {
      continue;
    }

    if (i % 2 == 0) {
      contents +=
          '\t\t<file disc="/Scene/UI/$basename" external="/$packName/Scene/UI/$basename"/>\n';
      //include korean weird naming convention
      contents +=
          '\t\t<file disc="/Scene/UI/${path.basenameWithoutExtension(basename)}_R.szs" external="/$packName/Scene/UI/$basename"/>\n';
    } else {
      String basenameNoLetter = basename.replaceAll(RegExp(r'_.*'), '');

      String s =
          '''\t\t<file disc="/Scene/UI/${basenameNoLetter}_E.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_F.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_G.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_I.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_S.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_M.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_Q.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_U.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_J.szs" external="/$packName/Scene/UI/$basename" />
\t\t<file disc="/Scene/UI/${basenameNoLetter}_K.szs" external="/$packName/Scene/UI/$basename" />\n''';

      contents += s;
    }
  }

  return "$contents\t\t";
}

class MiscItem {
  bool selected;
  String path;
  String name;

  MiscItem(this.name, this.path, this.selected);

  @override
  String toString() {
    return name;
  }
}
