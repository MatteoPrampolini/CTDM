import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../utils/gecko_utils.dart';

class GeckoCodes extends StatefulWidget {
  final String packPath;

  const GeckoCodes(this.packPath, {super.key});

  @override
  State<GeckoCodes> createState() => _GeckoCodesState();
}

class _GeckoCodesState extends State<GeckoCodes> {
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  List<Gecko> codes = [];
  int selectedCode = 0;
  late TextEditingController _nameController;
  late TextEditingController _authorController;
  late TextEditingController _descController;
  late TextEditingController _palController;
  late TextEditingController _usaController;
  late TextEditingController _japController;
  late TextEditingController _korController;

  @override
  void initState() {
    super.initState();
    loadCodes();
    codes.sort(compareGecko);

    _nameController = TextEditingController();
    _authorController = TextEditingController();
    _descController = TextEditingController();
    _palController = TextEditingController();
    _usaController = TextEditingController();
    _japController = TextEditingController();
    _korController = TextEditingController();
  }

  @override
  void dispose() {
    // _nameController.dispose();
    // _nameController.dispose();
    // _authorController.dispose();
    // _descController.dispose();
    // _palController.dispose();
    // _usaController.dispose();
    // _japController.dispose();
    // _korController.dispose();
    super.dispose();
  }

  void loadCodes() {
    codes = [];
    Directory codesFolder =
        Directory(path.join(widget.packPath, "..", "..", 'myCodes'));
    if (!codesFolder.existsSync()) {
      copyGeckoAssetsToPack(widget.packPath);
    }
    List<File> codeList = codesFolder.listSync().whereType<File>().toList();
    for (File code in codeList) {
      codes.add(fileToGeckoCode(code));
    }
  }

  void addCode() {
    setState(() {
      codes.add(Gecko("New Code", "", "", "", "", "",
          "please fill the description", "", false));
    });
  }

  void saveCode() {
    File oldSelectedFile = File(path.join(
        widget.packPath, "..", "..", 'myCodes', codes[selectedCode].baseName));
    if (oldSelectedFile.existsSync()) {
      oldSelectedFile.deleteSync();
    }
    codes[selectedCode].name = _nameController.value.text;
    codes[selectedCode].author = _authorController.value.text;
    codes[selectedCode].desc = _descController.value.text;
    codes[selectedCode].baseName = "${_nameController.value.text}.json";
    codes[selectedCode].pal = _palController.value.text;
    codes[selectedCode].usa = _usaController.value.text;
    codes[selectedCode].jap = _japController.value.text;
    codes[selectedCode].kor = _korController.value.text;

    String content = jsonEncode({
      'name': codes[selectedCode].name,
      'author': codes[selectedCode].author,
      'desc': codes[selectedCode].desc,
      'PAL': codes[selectedCode].pal.replaceAll(RegExp(r'[\n\r\s]+'), ''),
      'USA': codes[selectedCode].usa.replaceAll(RegExp(r'[\n\r\s]+'), ''),
      'JAP': codes[selectedCode].jap.replaceAll(RegExp(r'[\n\r\s]+'), ''),
      'KOR': codes[selectedCode].kor.replaceAll(RegExp(r'[\n\r\s]+'), '')
    });

    File selectedFile = File(path.join(
        widget.packPath, "..", "..", 'myCodes', codes[selectedCode].baseName));

    selectedFile.writeAsStringSync(content, mode: FileMode.write);
    writeGeckoTxt(codes, File(path.join(widget.packPath, 'gecko.txt')));

    loadCodes();
    codes.sort(compareGecko);
  }

  void deleteCode() {
    File selectedFile = File(path.join(
        widget.packPath, "..", "..", 'myCodes', codes[selectedCode].baseName));
    if (selectedFile.existsSync()) {
      selectedFile.deleteSync();
    }
    setState(() {
      codes.removeAt(selectedCode);
      selectedCode = selectedCode - 1;
      loadCodes();
      codes.sort(compareGecko);
    });
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    _nameController.text = codes[selectedCode].name;
    _authorController.text = codes[selectedCode].author;
    _descController.text = codes[selectedCode].desc;
    _palController.text = codes[selectedCode].pal;
    _usaController.text = codes[selectedCode].usa;
    _japController.text = codes[selectedCode].jap;
    _korController.text = codes[selectedCode].kor;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gecko Codes",
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
                  child: Text("CHEAT LIST",
                      style: TextStyle(color: Colors.amber, fontSize: 30)),
                ),
                const Divider(),
                for (int i = 0; i < codes.length; i++)
                  ListTile(
                    leading: const Icon(Icons.chevron_right),
                    selected: i == selectedCode,
                    title: Text(codes[i].name),
                    onTap: () => {
                      setState(
                        () => {selectedCode = i},
                      )
                    },
                  ),
                IconButton(
                    onPressed: addCode,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.amberAccent,
                    ))
              ])),
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: 500,
              child: Column(
                children: [
                  SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: !codes[selectedCode].mandatory,
                              controller: _nameController,
                              style: TextStyle(
                                  color: codes[selectedCode].mandatory
                                      ? Colors.white30
                                      : Colors.white),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cheat name',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              enabled: !codes[selectedCode].mandatory,
                              controller: _authorController,
                              style: TextStyle(
                                  color: codes[selectedCode].mandatory
                                      ? Colors.white30
                                      : Colors.white),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Author',
                              ),
                            ),
                          )
                        ],
                      )),
                  SizedBox(
                    height: 200,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GeckoTable(codes[selectedCode].pal, GameVersion.PAL,
                              _palController, codes[selectedCode].mandatory),
                          GeckoTable(codes[selectedCode].usa, GameVersion.USA,
                              _usaController, codes[selectedCode].mandatory),
                          GeckoTable(codes[selectedCode].jap, GameVersion.JAP,
                              _japController, codes[selectedCode].mandatory),
                          GeckoTable(codes[selectedCode].kor, GameVersion.KOR,
                              _korController, codes[selectedCode].mandatory)
                        ]),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextField(
                          enabled: !codes[selectedCode].mandatory,
                          controller: _descController,
                          maxLines: null,
                          minLines: null,
                          expands: true,
                          style: TextStyle(
                              color: codes[selectedCode].mandatory
                                  ? Colors.white30
                                  : Colors.white),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Desc',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 500,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.amberAccent)),
                                onPressed: codes[selectedCode].mandatory
                                    ? null
                                    : () => {saveCode(), setState(() {})},
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.black87),
                                )),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                  onPressed: codes[selectedCode].mandatory
                                      ? null
                                      : () => {deleteCode()},
                                  child: const Text("Delete")),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]));
  }
}

// ignore: must_be_immutable
class GeckoTable extends StatefulWidget {
  String codeString;
  GameVersion version;
  final TextEditingController _controller;
  bool disabled;
  GeckoTable(this.codeString, this.version, this._controller, this.disabled,
      {super.key});

  @override
  State<GeckoTable> createState() => _GeckoTableState();
}

class _GeckoTableState extends State<GeckoTable> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 8,
      child: TextField(
        enabled: !widget.disabled,
        controller: widget._controller,
        maxLines: null,
        minLines: null,
        expands: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: '${widget.version.name} Code',
        ),
        style:
            TextStyle(color: widget.disabled ? Colors.white30 : Colors.white),
      ),
    );
  }
}
