import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TrackConfig extends StatefulWidget {
  final String packPath;
  const TrackConfig(this.packPath, {super.key});

  @override
  State<TrackConfig> createState() => _TrackConfigState();
}
// File configFile = File("assets/config.txt");
// configFile.copy(path.join(tmp.path, 'config.txt'));

class _TrackConfigState extends State<TrackConfig> {
  @override
  void initState() {
    super.initState();
    createConfigFile(widget.packPath);
  }

  void createConfigFile(String packPath) {
    if (!File(path.join(packPath, 'config.txt')).existsSync()) {}
    File configFile = File("assets/config.txt");
    configFile.copy(path.join(packPath, 'config.txt'));
  }

  void resetConfigFile(String packPath) {
    File(path.join(packPath, 'config.txt')).deleteSync();
    createConfigFile(packPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track config",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text("Graphics not implemented yet, WIP",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline4?.fontSize,
                      color: Colors.white54),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please edit config.txt manually, sorry."),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton(
                        onPressed: () => {launchUrlString(widget.packPath)},
                        child: const Text("open folder")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: ElevatedButton(
                        onPressed: () => {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                {Navigator.pop(context)},
                                            child: const Text("cancel")),
                                        ElevatedButton(
                                            onPressed: () => {
                                                  resetConfigFile(
                                                      widget.packPath),
                                                  Navigator.pop(context)
                                                },
                                            child: const Text("yes, reset."))
                                      ],
                                      title: const Text('Are you sure?'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: const <Widget>[
                                            Text(
                                                'the operation is irreversible.'),
                                            Text(
                                                'Do you really want to reset?'),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            },
                        child: const Text("reset to default")),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
