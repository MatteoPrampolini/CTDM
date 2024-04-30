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
  final TextEditingController _textEditingController = TextEditingController();
  String? _errorText;
  final Map<String, int> dropdownItems = {
    'Large': 0,
    'Medium': 1,
    'Small': 2,
  };
  @override
  void initState() {
    super.initState();
    charList = createListOfCharacter(widget.packPath);
    if (charList.isNotEmpty) {
      selectedSizeIndex = charList[selectedChar].size.index;
      _textEditingController.text = charList[selectedChar].name;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (charList.isNotEmpty) {
      selectedSizeIndex = charList[selectedChar].size.index;
    }

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
              height: MediaQuery.of(context).size.height - 20,
              width: MediaQuery.of(context).size.width / 5,
              child: SingleChildScrollView(
                  child: Column(children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text("CHARACTERS",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 30)),
                ),
                const Divider(),
                for (int i = 0; i < charList.length; i++)
                  ListTile(
                    leading: const Icon(Icons.chevron_right),
                    selected: i == selectedChar,
                    selectedColor: Colors.redAccent,
                    title: Text(
                      charList[i].dirBasename,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => {
                      setState(
                        () {
                          selectedChar = i;
                          _textEditingController.text =
                              charList[selectedChar].name;
                        },
                      )
                    },
                  ),
                IconButton(
                    onPressed: () => {
                          setState(() {
                            createCustomCharacter(widget.packPath);
                            charList = createListOfCharacter(widget.packPath);
                            selectedSizeIndex =
                                charList[selectedChar].size.index;
                            _textEditingController.text =
                                charList[selectedChar].name;
                          }),
                        },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.amberAccent,
                    ))
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
                child: charList.isEmpty
                    ? const Text("You have no custom characters")
                    : SizedBox(
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
                                            charList[selectedChar].rewriteFile(
                                                selectedSizeIndex,
                                                charList[selectedChar].name);
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          });
                                        },
                                        items: dropdownItems.keys
                                            .map((String value) {
                                          return DropdownMenuItem<int>(
                                            value: dropdownItems[value]!,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.4,
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.white),
                                          controller: _textEditingController,
                                          onChanged: (value) {
                                            setState(() {
                                              _errorText =
                                                  NoSpecialCharactersValidator
                                                      .validate(value);
                                            });
                                          },
                                          cursorColor:
                                              Colors.redAccent.shade200,
                                          decoration: InputDecoration(
                                            focusColor: Colors.white,
                                            border: const OutlineInputBorder(),
                                            hintText: 'Insert character name',
                                            labelText: 'Character name',
                                            errorText: _errorText,
                                            errorStyle: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            const Divider(),
                            FileCheck(
                              findFilePath(charList[selectedChar].dir,
                                  path.basename('allkart')),
                              "Vehicles menu selection",
                            ),
                            FileCheck(
                              findFilePath(charList[selectedChar].dir,
                                  path.basename('allkart_BT')),
                              "Battle Mode vehicles menu selection",
                            ),
                            const Divider(),
                            FileCheck(
                              findFilePath(charList[selectedChar].dir,
                                  path.basename('driver.brres')),
                              "Driver",
                            ),
                            FileCheck(
                              findFilePath(charList[selectedChar].dir,
                                  path.basename('award.brres')),
                              "Award",
                            ),
                            Visibility(
                              visible:
                                  charList[selectedChar].size != Size.small,
                              child: Tooltip(
                                textAlign: TextAlign.left,
                                message:
                                    charList[selectedChar].size == Size.medium
                                        ? "for Peach or Daisy only."
                                        : "for Rosalina only.",
                                child: FileCheck(
                                  findFilePath(charList[selectedChar].dir,
                                      path.basename('award3.brres')),
                                  "Award 3 ",
                                ),
                              ),
                            ),
                            const Divider(),
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: charList[selectedChar]
                                      .fileListPath
                                      .length,
                                  itemBuilder: (context, index) {
                                    String file = charList[selectedChar]
                                        .fileListPath[index];
                                    return FileCheck(
                                      findFilePath(
                                          Directory(path.join(
                                              charList[selectedChar].dir.path,
                                              'karts')),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () async => {
                                            if (!Platform.isLinux)
                                              {
                                                launchUrlString(
                                                    charList[selectedChar]
                                                        .dir
                                                        .path)
                                              },
                                            if (Platform.isLinux)
                                              {
                                                await Process.start(
                                                    'xdg-open', [
                                                  charList[selectedChar]
                                                      .dir
                                                      .path
                                                ]),

                                                //await
                                              }
                                          },
                                      child: const Text("open folder",
                                          style:
                                              TextStyle(color: Colors.white))),
                                  SizedBox(
                                    height: 28,
                                    width: 200,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.amberAccent),
                                        onPressed: () => setState(() {
                                              charList[selectedChar]
                                                  .rewriteFile(
                                                      selectedSizeIndex,
                                                      _textEditingController
                                                          .text);
                                              charList = createListOfCharacter(
                                                  widget.packPath);
                                              selectedSizeIndex =
                                                  charList[selectedChar]
                                                      .size
                                                      .index;
                                              _textEditingController.text =
                                                  charList[selectedChar].name;
                                            }),
                                        child: const Text(
                                          "Save",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20),
                                        )),
                                  ),
                                  ElevatedButton(
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () => setState(() {
                                            charList = createListOfCharacter(
                                                widget.packPath);
                                            selectedSizeIndex =
                                                charList[selectedChar]
                                                    .size
                                                    .index;
                                            _textEditingController.text =
                                                charList[selectedChar].name;
                                          }),
                                      child: const Text("refresh",
                                          style:
                                              TextStyle(color: Colors.white))),
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
  //String? customPath;
  // ignore: use_key_in_widget_constructors
  FileCheck(this.file, this.desc);

  @override
  State<FileCheck> createState() => _FileCheckState();
}

class _FileCheckState extends State<FileCheck> {
  @override
  Widget build(BuildContext context) {
    String message =
        widget.file.path.split('myCharacters')[1].replaceAll(r'\', r'/');

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
              message: "$message not found",
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

class NoSpecialCharactersValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    // Controlla la lunghezza del testo
    if (value.length >= 25) {
      return 'Text length must be less than 20 characters.';
    }
    // Definiamo l'espressione regolare per accettare solo lettere, numeri e spazi.
    RegExp regex = RegExp(r'^[a-zA-Z0-9\s]+$');

    if (!regex.hasMatch(value)) {
      return 'Special characters are not allowed.';
    }

    return null; // Il valore è valido
  }
}
