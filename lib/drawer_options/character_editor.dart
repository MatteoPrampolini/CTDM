import 'dart:io';
import 'package:ctdm/utils/character_utiles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

class CharEditor extends StatefulWidget {
  final String packPath;
  const CharEditor(this.packPath, {super.key});

  @override
  State<CharEditor> createState() => _CharEditorState();
}

class _CharEditorState extends State<CharEditor> {
  int selectedChar = 0;
  int selectedSizeIndex = 2;
  late List<CustomCharacter> charList;
  final Map<String, int> dropdownItems = {
    'Large': 0,
    'Medium': 1,
    'Small': 2,
  };
  @override
  void initState() {
    super.initState();
    charList = createListOfCharacter(widget.packPath);
    selectedSizeIndex = charList[selectedChar].size.index;
  }

  @override
  Widget build(BuildContext context) {
    selectedSizeIndex = charList[selectedChar].size.index;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Character editor",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.amberAccent)),
              height: MediaQuery.of(context).size.height - 30,
              width: MediaQuery.of(context).size.width / 5,
              child: SingleChildScrollView(
                  child: Column(children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text("CHARACTERS",
                      style: TextStyle(color: Colors.amber, fontSize: 30)),
                ),
                const Divider(),
                for (int i = 0; i < charList.length; i++)
                  ListTile(
                    leading: const Icon(Icons.chevron_right),
                    selected: i == selectedChar,
                    title: Text(charList[i].name),
                    onTap: () => {
                      setState(
                        () => selectedChar = i,
                      )
                    },
                  ),
              ])),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: MediaQuery.of(context).size.width / 10,
            ),
            child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 700,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: path.join(
                                    path.basename(
                                        charList[selectedChar].dir.path),
                                    'icons',
                                    'icon64.png'),
                                child: Image.file(
                                    scale: 1,
                                    File(path.join(
                                                    charList[selectedChar]
                                                        .dir
                                                        .path,
                                                    'icons',
                                                    'icon64.png'))
                                                .existsSync() &&
                                            File(path.join(
                                                    charList[selectedChar]
                                                        .dir
                                                        .path,
                                                    'icons',
                                                    'icon64.png'))
                                                .existsSync()
                                        ? File(path.join(
                                            charList[selectedChar].dir.path,
                                            'icons',
                                            'icon64.png'))
                                        : File(
                                            path.join(
                                                path.dirname(Platform
                                                    .resolvedExecutable),
                                                "data",
                                                "flutter_assets",
                                                "assets",
                                                "characters",
                                                "images64",
                                                "not_found.png"),
                                          )),
                              ),
                              Tooltip(
                                message: path.join(
                                    path.basename(
                                        charList[selectedChar].dir.path),
                                    'icons',
                                    'icon32.png'),
                                child: Image.file(
                                    scale: 0.69,
                                    File(path.join(
                                                    charList[selectedChar]
                                                        .dir
                                                        .path,
                                                    'icons',
                                                    'icon32.png'))
                                                .existsSync() &&
                                            File(path.join(
                                                    charList[selectedChar]
                                                        .dir
                                                        .path,
                                                    'icons',
                                                    'icon32.png'))
                                                .existsSync()
                                        ? File(path.join(
                                            charList[selectedChar].dir.path,
                                            'icons',
                                            'icon32.png'))
                                        : File(
                                            path.join(
                                                path.dirname(Platform
                                                    .resolvedExecutable),
                                                "data",
                                                "flutter_assets",
                                                "assets",
                                                "characters",
                                                "images64",
                                                "not_found.png"),
                                          )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: FocusScope(
                                  child: DropdownButton<int>(
                                    value: selectedSizeIndex,
                                    onChanged: (int? newIndex) {
                                      setState(() {
                                        selectedSizeIndex = newIndex!;
                                        charList[selectedChar]
                                            .changeSize(selectedSizeIndex);
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      });
                                    },
                                    items:
                                        dropdownItems.keys.map((String value) {
                                      return DropdownMenuItem<int>(
                                        value: dropdownItems[value]!,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            ]),
                        const Divider(),
                        FileCheck(
                            findFilePath(charList[selectedChar].dir,
                                path.basename('allkart')),
                            "Vehicles menu selection",
                            '/allkart.szs'),
                        const Divider(),
                        FileCheck(
                            findFilePath(charList[selectedChar].dir,
                                path.basename('driver.brres')),
                            "Driver",
                            '/driver.brres'),
                        FileCheck(
                            findFilePath(charList[selectedChar].dir,
                                path.basename('award.brres')),
                            "Award",
                            '/award.brres'),
                        const Divider(),
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 2.15,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  charList[selectedChar].fileListPath.length,
                              itemBuilder: (context, index) {
                                String file =
                                    charList[selectedChar].fileListPath[index];
                                return FileCheck(
                                  findFilePath(charList[selectedChar].dir,
                                      path.basename(file)),
                                  findFirstKeyByValue(
                                      vehicles, path.basename(file)),
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () async => {
                                        if (!Platform.isLinux)
                                          {
                                            launchUrlString(
                                                charList[selectedChar].dir.path)
                                          },
                                        if (Platform.isLinux)
                                          {
                                            await Process.start('open', [
                                              charList[selectedChar].dir.path
                                            ]),

                                            //await
                                          }
                                      },
                                  child: const Text("open folder")),
                              ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  child: const Text("refresh")),
                            ],
                          ),
                        ),
                      ],
                    ))),
          )
        ]));
  }
}

// ignore: must_be_immutable
class FileCheck extends StatefulWidget {
  String desc;
  File file;
  String? customPath;
  // ignore: use_key_in_widget_constructors
  FileCheck(this.file, this.desc, [this.customPath]);

  @override
  State<FileCheck> createState() => _FileCheckState();
}

class _FileCheckState extends State<FileCheck> {
  @override
  Widget build(BuildContext context) {
    String message = widget.file.path
        .split('myCharacters')[1]
        .replaceRange(0, 1, '')
        .split(';')[0];

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(path.basename(widget.desc)),
      // Text(path.basename(widget.file.path)),

      widget.file.existsSync()
          ? Tooltip(
              message: message,
              child: const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.check,
                    color: Colors.amber,
                  )))
          : Tooltip(
              message: "$message${widget.customPath} not found",
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            )
    ]);
  }
}
