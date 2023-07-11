import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

readRegionFile(String packPath) {
  File regionFile = File(path.join(packPath, 'region.txt'));
  if (!regionFile.existsSync()) {
    return "";
  }
  return regionFile.readAsStringSync();
}

class Multiplayer extends StatefulWidget {
  final String packPath;

  const Multiplayer(this.packPath, {super.key});

  @override
  State<Multiplayer> createState() => _MultiplayerState();
}

class _MultiplayerState extends State<Multiplayer> {
  bool onlineEnabled = false;
  late TextEditingController regionTextField;

  @override
  void initState() {
    regionTextField = TextEditingController();
    String regionFileContent = readRegionFile(widget.packPath);
    if (regionFileContent == "") {
      regionTextField.text = "0000";
      onlineEnabled = false;
    } else {
      regionTextField.text = regionFileContent.split(';').first;
      onlineEnabled = regionFileContent.split(';').last == "true";
    }
    super.initState();
  }

  @override
  void dispose() {
    regionTextField.dispose();
    super.dispose();
  }

  saveRegion() {
    File regionFile = createRegionFile(widget.packPath);
    String contents = "${regionTextField.text};${onlineEnabled.toString()}";
    regionFile.writeAsStringSync(contents, mode: FileMode.write);
  }

  createRegionFile(String packPath) {
    File regionFile = File(path.join(packPath, 'region.txt'));
    if (!regionFile.existsSync()) {
      regionFile.createSync();
    }
    return regionFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Multiplayer",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        onTriggered: () => _launchUrl(Uri.parse(
                            "https://wiki.tockdom.com/w/index.php?title=Custom_Track_Regions#apply")),
                        message:
                            "https://wiki.tockdom.com/w/index.php?title=Custom_Track_Regions#apply",
                        enableFeedback: true,
                        child: Text(
                          "Insert region ID:",
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.fontSize),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.6,
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 350,
                                height: 200,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 40.0,
                                          ),
                                          decoration:
                                              const InputDecoration.collapsed(
                                                  hintText: '000000'),
                                          controller: regionTextField,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(6),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]'))
                                          ]),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: CheckboxListTile(
                                        activeColor: Colors.redAccent,
                                        title: const Text(
                                          "Enable",
                                          style: TextStyle(fontSize: 25),
                                        ),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            onlineEnabled = value!;
                                          });
                                        },
                                        value: onlineEnabled,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 65,
                                width: 200,
                                child: ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.amberAccent)),
                                  child: const Text(
                                    "Save",
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 30),
                                  ),
                                  onPressed: () => {
                                    saveRegion(),
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            Navigator.of(context).pop(true);
                                          });
                                          return const AlertDialog(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Saved"),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Icon(Icons.thumb_up),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]))));
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
