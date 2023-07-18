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

class CustomUI extends StatefulWidget {
  final String packPath;
  const CustomUI(this.packPath, {super.key});

  @override
  State<CustomUI> createState() => _CustomUIState();
}

class _CustomUIState extends State<CustomUI> {
  late List<bool> values;
  File getFileFromIndex(int index) {
    String filePath = '';
    if (index % 2 == 0) {
      //from ORIGINAL_DISC
      String basename =
          '${Scene.values.elementAt((index / 2).floor()).name.toCapitalized()}.szs';
      filePath = path.join(
          path.dirname(
            (path.dirname(widget.packPath)),
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

  List<bool> loadUIconfig() {
    List<bool> values = List.generate(Scene.values.length * 2, (index) => false,
        growable: false);
    File uiFile = File(path.join(widget.packPath, 'ui.txt'));
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

  void saveUIConfig(File uiFile, List<bool> values) {
    uiFile.writeAsStringSync(jsonEncode(values));
  }

  @override
  void initState() {
    values = loadUIconfig();

    super.initState();
  }

  Future<void> createFiles() async {
    for (int i = 0; i < values.length; i++) {
      if (values[i] == false) continue;
      File tmpFile = getFileFromIndex(i);
      tmpFile.copy(
          path.join(widget.packPath, 'myUI', path.basename(tmpFile.path)));
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
                        )
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
