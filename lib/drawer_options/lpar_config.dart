import 'dart:io';

import 'package:ctdm/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

class LparConfig extends StatefulWidget {
  final String packPath;
  const LparConfig(this.packPath, {super.key});

  @override
  State<LparConfig> createState() => _LparConfigState();
}
// File configFile = File("assets/config.txt");
// configFile.copy(path.join(tmp.path, 'config.txt'));

class _LparConfigState extends State<LparConfig> {
  @override
  void initState() {
    super.initState();
    createLparFile(widget.packPath);
  }

  void createLparFile(String packPath) async {
    if (!File(path.join(packPath, 'lpar.txt')).existsSync()) {
      try {
        final _ = await Process.start('wlect',
            ['create', 'lpar', '--dest', path.join(packPath, 'lpar.txt')],
            runInShell: false);
      } on Exception catch (_) {
        logString(LogType.ERROR, _.toString());
      }
    }
  }

  void resetLparFile(String packPath) {
    File(path.join(packPath, 'lpar.txt')).deleteSync();
    createLparFile(packPath);
  }

  @override
  Widget build(BuildContext context) {
    Process pr;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "LPAR config",
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
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                      color: Colors.white54),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Please edit lpar.txt manually, sorry."),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton(
                        onPressed: () async => {
                              if (!Platform.isLinux)
                                {launchUrlString(widget.packPath)},
                              if (Platform.isLinux)
                                {
                                  pr = await Process.start(
                                      'open', [widget.packPath]),
                                  await pr.exitCode,
                                  //await
                                }
                            },
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
                                                  resetLparFile(
                                                      widget.packPath),
                                                  Navigator.pop(context)
                                                },
                                            child: const Text("yes, reset."))
                                      ],
                                      title: const Text('Are you sure?'),
                                      content: const SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
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
