import 'dart:convert';
import 'dart:io';
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

// String getNameFromIndex(index) {
//   if (index % 2 == 0) {
//     //from ORIGINAL_DISC
//     return '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}.szs';
//   } else {
//     //from assets
//     return '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}_U.szs';
//   }
// }

File getFileFromIndex(String packPath, int index) {
  String filePath = '';
  if (index % 2 == 0) {
    //from ORIGINAL_DISC
    String basename =
        '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}.szs';
    filePath = path.join(
        path.dirname(
          (path.dirname(packPath)),
        ),
        'ORIGINAL_DISC',
        'files',
        'Scene',
        'UI',
        basename);
  } else {
    //from assets
    String basename =
        '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}_U.szs';

    filePath = path.join(path.dirname(Platform.resolvedExecutable), "data",
        "flutter_assets", "assets", "scene", basename);
  }

  return File(filePath);
}

class CustomUI extends StatefulWidget {
  final String packPath;
  const CustomUI(this.packPath, {super.key});

  @override
  State<CustomUI> createState() => _CustomUIState();
}

class _CustomUIState extends State<CustomUI> {
  late List<bool> values;

  @override
  void initState() {
    values = loadUIconfig(widget.packPath);

    super.initState();
  }

  Future<void> createFiles() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Custom UI",
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
                const Text("Select which files you want to replace:"),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 + 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            child: const Text(
                              "Create files",
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () async => createFiles()),
                        ElevatedButton(
                          child: const Text(
                            "Open folder",
                            textAlign: TextAlign.center,
                          ),
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
                                await Process.start('open',
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

String createXmlStringForUi(String packPath, List<bool> filesBool) {
  String contents = "\t\t<!--CUSTOM UI-->\n";
  for (int i = 0; i < filesBool.length; i++) {
    if (filesBool[i] == false || i == 12 || i == 13) {
      continue;
    }
    String basename = path.basename(getFileFromIndex(packPath, i).path);

    if (i % 2 == 0) {
      contents +=
          '\t\t<file disc="/Scene/UI/$basename" external="/v9/Scene/UI/$basename"/>\n';
    } else {
      String basenameNoLetter = basename.replaceAll(RegExp(r'_.*'), '');
      String packName = path.basename(packPath);
      String s =
          '''\t\t<file disc="/Scene/UI/${basenameNoLetter}_E.szs" external="/v9/Scene/UI/$basename" />
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