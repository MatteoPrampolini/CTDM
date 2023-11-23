import 'dart:io';

import 'package:ctdm/utils/xml_json_utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class RenamePack extends StatefulWidget {
  final String packPath;
  const RenamePack(this.packPath, {super.key});

  @override
  State<RenamePack> createState() => _RenamePackState();
}

bool checkValidTextfield(String name, String id) {
  if (name == id) return false;
  final validCharactersName = RegExp(r'^[a-zA-Z0-9_ ]+$');
  final validCharactersId = RegExp(r'^[a-zA-Z0-9_]+$');

  if (name == '' ||
      name == 'MyPackName' ||
      !validCharactersName.hasMatch(name)) {
    return false;
  }
  if (id == '' ||
      id == 'mypack_uniquename' ||
      !validCharactersId.hasMatch(id)) {
    return false;
  }
  return true;
}

class _RenamePackState extends State<RenamePack> {
  late bool enableSaveBtn = false;
  late String packNameChosen = '';
  late String packIdChosen = '';
  late TextEditingController _chosenNameController;
  late TextEditingController _chosenIdController;
  late SharedPreferences prefs;
  late String version = "";
  late String dolphin = "";
  late String game = "";
  //late String isoVersion = 'PAL';

  // // void getIsoVersion() async {
  //   prefs = await SharedPreferences.getInstance();
  //   isoVersion = prefs.getString('isoVersion')!;
  // }

  @override
  void initState() {
    loadSettings();
    super.initState();

    if (widget.packPath.contains('tmp_pack_')) {
      packNameChosen = 'MyPackName';
      packIdChosen = 'mypack_uniquename';
    } else {
      packNameChosen = path.basename(widget.packPath);
      final String xmlPath = path.join(widget.packPath, '$packNameChosen.xml');
      File xmlFile = File(xmlPath);
      if (!xmlFile.existsSync()) {
        createXmlFile(xmlPath);
      }

      String contents = xmlFile.readAsStringSync();
      packIdChosen = contents.split(RegExp(r'patch id='))[1];

      packIdChosen = packIdChosen
          .replaceRange(packIdChosen.indexOf(r'/'), null, '')
          .replaceAll('"', '');
    }
    _chosenNameController = TextEditingController.fromValue(
      TextEditingValue(
        text: packNameChosen, //path.basename(widget.packPath),
      ),
    );
    _chosenNameController = TextEditingController.fromValue(
      TextEditingValue(
        text: packNameChosen, //path.basename(widget.packPath),
      ),
    );
    _chosenIdController = TextEditingController.fromValue(
      TextEditingValue(
        text: packIdChosen, //path.basename(widget.packPath),
      ),
    );

    //getIsoVersion();
  }

  @override
  void dispose() {
    _chosenNameController.dispose();
    _chosenIdController.dispose();
    super.dispose();
  }

  loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    version = prefs.getString('version')!;
    dolphin = prefs.getString('dolphin')!;
    game = prefs.getString('game')!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pack name",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
              }),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "please choose your pack name and id",
                    style: TextStyle(
                        fontSize: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.fontSize),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "pack name:",
                            style: TextStyle(color: Colors.white54),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 15,
                            child: TextField(
                                onChanged: (newvalue) => {
                                      packNameChosen = newvalue,
                                      setState(
                                        () => enableSaveBtn =
                                            checkValidTextfield(
                                                packNameChosen, packIdChosen),
                                      ),
                                    },
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                autofocus: false,
                                keyboardType: TextInputType.multiline,
                                maxLines: 1,
                                controller: _chosenNameController),
                          ),
                          const Tooltip(
                            message: "basically the name of the folder",
                            child: IconButton(
                                icon: Icon(Icons.info), onPressed: null),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "patch id:",
                          style: TextStyle(color: Colors.white54),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: TextField(
                              //onEditingComplete: () => print("editin complete"),
                              // onSubmitted: (value) => print('submitted'),
                              onChanged: (newvalue) => {
                                    packIdChosen = newvalue,
                                    setState(() => enableSaveBtn =
                                        checkValidTextfield(
                                            packNameChosen, packIdChosen)),
                                  },
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              autofocus: false,
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              controller: _chosenIdController),
                        ),
                        const Tooltip(
                          message:
                              "the ID riivolution will use to identify your pack",
                          child: IconButton(
                              icon: Icon(Icons.info), onPressed: null),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            fixedSize:
                                MaterialStateProperty.all(const Size(150, 50))),
                        onPressed: enableSaveBtn
                            ? () => {
                                  saveAndRenamePack(
                                      widget.packPath,
                                      packNameChosen,
                                      packIdChosen,
                                      version,
                                      game,
                                      dolphin),
                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const MyApp(),
                                  //   ),
                                  // )
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MyHomePage()))
                                }
                            : null,
                        child: const Text("SAVE")),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
