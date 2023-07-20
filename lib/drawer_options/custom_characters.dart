// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:ctdm/utils/character_utiles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CustomCharacters extends StatefulWidget {
  final String packPath;
  const CustomCharacters(this.packPath, {super.key});

  @override
  State<CustomCharacters> createState() => _CustomCharactersState();
}

class _CustomCharactersState extends State<CustomCharacters> {
  List<MapEntry<String, String>> allCharacters = [];
  List<MapEntry<String, String>> lightCharacters = [];
  List<MapEntry<String, String>> mediumCharacters = [];
  List<MapEntry<String, String>> heavyCharacters = [];
  final int charactersPerPage = 8;

  @override
  void initState() {
    super.initState();
    // Divide the characters into separate lists
    allCharacters = characters2D.entries.toList();
    lightCharacters = allCharacters.sublist(0, charactersPerPage);
    mediumCharacters =
        allCharacters.sublist(charactersPerPage, charactersPerPage * 2);
    heavyCharacters = allCharacters.sublist(charactersPerPage * 2);
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
            Row(
              children: [
                ElevatedButton(
                    onPressed: () => {}, child: const Text("Create")),
                ElevatedButton(onPressed: () => {}, child: const Text("Edit")),
              ],
            ),
            Expanded(
              child: Transform.scale(
                scale: 0.95,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SingleChildScrollView(
                    // Use SingleChildScrollView to scroll through the GridViews
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child:
                              _buildGridView(lightCharacters, widget.packPath),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child:
                              _buildGridView(mediumCharacters, widget.packPath),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child:
                              _buildGridView(heavyCharacters, widget.packPath),
                        ),
                      ],
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
  CharacterRow(this.name, this.icon, this.replace, this.packPath, {super.key});

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
          IconButton(
              iconSize: 64,
              padding: const EdgeInsets.only(left: 15),
              onPressed: () async => {
                    widget.replace = await searchForDir(widget.packPath),
                    setState(() => {}),
                  },
              icon: const Icon(
                Icons.folder,
                size: 64,
                color: Colors.amberAccent,
              )),

          Visibility(
            visible: widget.replace.existsSync() &&
                File(path.join(widget.replace.path, 'icons', 'icon64.png'))
                    .existsSync(),
            child: IconButton(
                iconSize: 32,
                padding: EdgeInsets.zero,
                onPressed: () => {
                      setState(() => {
                            widget.replace =
                                Directory("invalidPath#################")
                          })
                    },
                icon: const Icon(
                  Icons.close,
                  size: 32,
                  color: Colors.red,
                )),
          ),
        ],
      ),
    );
  }
}

Widget _buildGridView(
    List<MapEntry<String, String>> characters, String packPath) {
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
        return CharacterRow(characters[index].key, icon,
            Directory("invalidPath#################"), packPath);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // ignore: deprecated_member_use
          crossAxisCount:
              MediaQueryData.fromView(WidgetsBinding.instance.window)
                          .size
                          .width >
                      800
                  ? 2
                  : 1,
          mainAxisExtent: 100,
          crossAxisSpacing: 10,
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
