// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:ctdm/utils/character_utiles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

class CustomCharacters extends StatefulWidget {
  final String packPath;
  const CustomCharacters(this.packPath, {super.key});

  @override
  State<CustomCharacters> createState() => _CustomCharactersState();
}

int calcCustomChar(String packPath) {
  Directory myCharDir = Directory(path
      .join(path.join(path.dirname(path.dirname(packPath)), 'myCharacters')));
  if (!myCharDir.existsSync()) {
    return 0;
  }
  return myCharDir.listSync().whereType<Directory>().length;
}

class _CustomCharactersState extends State<CustomCharacters> {
  List<MapEntry<String, String>> allCharacters = [];
  List<MapEntry<String, String>> lightCharacters = [];
  List<MapEntry<String, String>> mediumCharacters = [];
  List<MapEntry<String, String>> heavyCharacters = [];
  late File txt;
  final int charactersPerPage = 8;
  List<String> characterPaths = [];
  @override
  void initState() {
    super.initState();
    // Divide the characters into separate lists
    allCharacters = characters2D.entries.toList();
    lightCharacters = allCharacters.sublist(0, charactersPerPage);
    mediumCharacters =
        allCharacters.sublist(charactersPerPage, charactersPerPage * 2);
    heavyCharacters = allCharacters.sublist(charactersPerPage * 2);
    txt = File(path.join(widget.packPath, 'characters.txt'));

    if (!txt.existsSync()) {
      txt.createSync();
      String contents = "";
      for (var element in allCharacters) {
        contents += "${element.key};\n";
      }
      txt.writeAsStringSync(contents);
    }
    characterPaths = loadConfig(txt);
  }

  List<String> loadConfig(File txt) {
    List<String> replacementsPaths = [];
    txt.readAsLinesSync().forEach((String line) {
      String charPath = line.split(";")[1];

      replacementsPaths.add(charPath);
    });
    return replacementsPaths;
  }

  bool charIsUpdated(CharacterUpdated n) {
    if (n.path == "invalidPath#################") {
      characterPaths[n.index] = "";
    } else {
      characterPaths[n.index] = path.basename(n.path);
    }

    //print("ho salvato il path");
    String contents = "";
    for (var element in allCharacters) {
      contents +=
          "${element.key};${characterPaths[allCharacters.indexOf(element)]}\n";
    }
    txt.writeAsStringSync(contents);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Custom characters",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.red.shade700),
      ),
      body: Center(
        child: Column(
          children: [
            NotificationListener<CharacterUpdated>(
              onNotification: charIsUpdated,
              child: Expanded(
                child: Transform.scale(
                  scale: 0.95,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: SingleChildScrollView(
                      // Use SingleChildScrollView to scroll through the GridViews
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Your workspace has ',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 28,
                                      fontFamily: 'MarioMaker'),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: calcCustomChar(widget.packPath)
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' custom characters'),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () => {},
                                    child: const Text("Create")),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: TextButton(
                                      onPressed: () async => {
                                            if (!Directory(path.join(path.join(
                                                    path.dirname(path.dirname(
                                                        widget.packPath)),
                                                    'myCharacters')))
                                                .existsSync())
                                              {
                                                Directory(path.join(path.join(
                                                        path.dirname(
                                                            path.dirname(widget
                                                                .packPath)),
                                                        'myCharacters')))
                                                    .createSync()
                                              }
                                            else
                                              1 + 1, //added to avoid compiler error
                                            if (!Platform.isLinux)
                                              {
                                                launchUrlString(path.join(
                                                    path.join(
                                                        path.dirname(
                                                            path.dirname(widget
                                                                .packPath)),
                                                        'myCharacters')))
                                              }
                                            else if (Platform.isLinux)
                                              {
                                                await Process.start('open', [
                                                  path.join(path.join(
                                                      path.dirname(path.dirname(
                                                          widget.packPath)),
                                                      'myCharacters'))
                                                ]),

                                                //await
                                              }
                                          },
                                      child: const Text("Import")),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: _buildGridView(lightCharacters,
                                widget.packPath, characterPaths, 0),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: _buildGridView(mediumCharacters,
                                widget.packPath, characterPaths, 1),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: _buildGridView(heavyCharacters,
                                widget.packPath, characterPaths, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterRow extends StatefulWidget {
  String name;
  File icon;
  Directory replace;
  String packPath;
  int index;
  CharacterRow(this.name, this.icon, this.replace, this.packPath, this.index,
      {super.key});

  @override
  State<CharacterRow> createState() => _CharacterRowState();
}

class _CharacterRowState extends State<CharacterRow> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      //decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.amber),
            ),
            child: Image.file(
              widget.icon,
              scale: 0.69,
            ),
          ),
          const Icon(Icons.arrow_right_alt, size: 64),
          //Text(widget.name),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white),
            ),
            child: Image.file(
                scale: 0.69,
                widget.replace.existsSync() &&
                        File(path.join(
                                widget.replace.path, 'icons', 'icon64.png'))
                            .existsSync()
                    ? File(
                        path.join(widget.replace.path, 'icons', 'icon64.png'))
                    : File(
                        path.join(
                            path.dirname(Platform.resolvedExecutable),
                            "data",
                            "flutter_assets",
                            "assets",
                            "characters",
                            "images64",
                            "not_found.png"),
                      )),
          ),
          Expanded(
            child: IconButton(
                iconSize: 64,
                padding: const EdgeInsets.only(left: 15),
                onPressed: () async => {
                      widget.replace = await searchForDir(widget.packPath),
                      CharacterUpdated(widget.index, widget.replace.path)
                          .dispatch(context),
                      setState(() {})
                    },
                icon: const Icon(
                  Icons.folder,
                  size: 64,
                  color: Colors.amberAccent,
                )),
          ),

          Visibility(
            visible: widget.replace.existsSync() &&
                File(path.join(widget.replace.path, 'icons', 'icon64.png'))
                    .existsSync(),
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  onPressed: () => {
                        widget.replace =
                            Directory("invalidPath#################"),
                        CharacterUpdated(widget.index, widget.replace.path)
                            .dispatch(context),
                        setState(() {})
                      },
                  icon: const Icon(
                    Icons.close,
                    size: 32,
                    color: Colors.red,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGridView(List<MapEntry<String, String>> characters,
    String packPath, List<String> charPathList, int mult) {
  return SingleChildScrollView(
    child: GridView.builder(
      shrinkWrap: true,
      itemCount: characters.length,
      itemBuilder: (BuildContext context, int index) {
        String filebasename = characters[index].value;
        File icon = File(
          path.join(
            path.dirname(Platform.resolvedExecutable),
            "data",
            "flutter_assets",
            "assets",
            "characters",
            "images64",
            "tt_${filebasename}_64x64.tpl-0.png",
          ),
        );
        String charPath = charPathList.elementAt(index + 8 * mult).isEmpty
            ? "invalidPath#################"
            : path.join(path.join(path.dirname(path.dirname(packPath)),
                'myCharacters', charPathList.elementAt(index + 8 * mult)));
        return CharacterRow(characters[index].key, icon, Directory(charPath),
            packPath, index + 8 * mult);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              // ignore: deprecated_member_use
              MediaQueryData.fromView(WidgetsBinding.instance.window)
                          .size
                          .width >
                      910
                  ? 2
                  : 1,
          mainAxisExtent: 100,
          crossAxisSpacing: 50,
          mainAxisSpacing: 10),
    ),
  );
}

Future<Directory> searchForDir(String packPath) async {
  String? result = await FilePicker.platform.getDirectoryPath(
      initialDirectory: path.join(packPath, '..', '..', 'myCharacters'));
  if (result != null) {
    return Directory(result);
    // if(await Directory(result).exists()){

    // }
  }
  return Directory("invalidPath#################");
}

void saveCharacterTxt(File txt) {
  String content = "";
  txt.writeAsStringSync(content, mode: FileMode.write);
}

class CharacterUpdated extends Notification {
  final int index;
  final String path;
  CharacterUpdated(this.index, this.path);
}
