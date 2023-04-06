import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class GeckoCodes extends StatefulWidget {
  final String packPath;

  const GeckoCodes(this.packPath, {super.key});

  @override
  State<GeckoCodes> createState() => _GeckoCodesState();
}

class _GeckoCodesState extends State<GeckoCodes> {
  List<Gecko> codes = [];
  @override
  void initState() {
    loadCodes();
    super.initState();
  }

  void loadCodes() {
    Directory codesFolder = Directory(
        path.join(path.dirname(path.dirname(widget.packPath)), 'MyCodes'));
    if (!codesFolder.existsSync()) {
      codesFolder.createSync();
    }
    List<File> codeList = codesFolder.listSync().whereType<File>().toList();
    for (File code in codeList) {
      var json = jsonDecode(code.readAsStringSync());
      //process json e append codes
    }
  }

  @override
  Widget build(BuildContext context) {
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
          SingleChildScrollView(
              child: Column(children: [
            for (int i = 0; i < codes.length; i++) Text(codes[i].name)
          ])),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: 400,
              child: Column(
                children: [
                  Text("Name,Author,Save row"),
                  SizedBox(
                    height: 300,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GeckoTable("", GameVersion.PAL),
                          GeckoTable("", GameVersion.USA),
                          GeckoTable("", GameVersion.JAP),
                          GeckoTable("", GameVersion.KOR)
                        ]),
                  ),
                ],
              ),
            ),
          ),
          const Text("select code")
        ]));
  }
}

class Gecko {
  String name;
  String? author;
  String pal;
  String usa;
  String kor;
  String jap;
  Gecko(this.name, this.pal, this.usa, this.kor, this.jap, {this.author});
}

enum GameVersion { PAL, USA, JAP, KOR }

class GeckoTable extends StatefulWidget {
  String codeString;
  GameVersion version;
  GeckoTable(this.codeString, this.version, {super.key});

  @override
  State<GeckoTable> createState() => _GeckoTableState();
}

class _GeckoTableState extends State<GeckoTable> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width / 8,
      child: TextField(
        maxLines: null,
        minLines: null,
        expands: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Insert ${widget.version.name} Code',
        ),
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
