import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher_string.dart';

int compareAlphamagically(File a, File b) {
  if (int.tryParse(path.basenameWithoutExtension(a.path)) == null &&
      int.tryParse(path.basenameWithoutExtension(a.path)) == null) {
    return a.path.compareTo(b.path);
  }
  if (int.tryParse(path.basenameWithoutExtension(a.path)) == null &&
      int.tryParse(path.basenameWithoutExtension(b.path)) != null) {
    return -1;
  }
  if (int.tryParse(path.basenameWithoutExtension(a.path)) != null &&
      int.tryParse(path.basenameWithoutExtension(b.path)) == null) {
    return 1;
  }
  return int.parse(path.basenameWithoutExtension(a.path))
      .compareTo(int.parse(path.basenameWithoutExtension(b.path)));
}

class CupIconsWindow extends StatefulWidget {
  final String packPath;
  const CupIconsWindow(this.packPath, {super.key});

  @override
  State<CupIconsWindow> createState() => _CupIconsWindowState();
}

Future<int> getNumberOfIconsFromConfig(String packPath) async {
  if (!File(path.join(packPath, 'config.txt')).existsSync()) {
    return -1;
  } else {
    try {
      //wlect config config.txt
      final process = await Process.run(
          'wlect',
          [
            'dump',
            path.join(packPath, 'config.txt'),
          ],
          runInShell: true);

      String result = process.stdout;
      return int.parse(result
          .split(RegExp(r'racing cups defined.'))[0]
          .split(RegExp(r'\n'))
          .last
          .trim());
    } on Exception catch (_) {
      return -2;
    }
  }
}

class _CupIconsWindowState extends State<CupIconsWindow> {
  int nCups = -99;
  @override
  void initState() {
    setup();
    super.initState();
  }

  void setup() async {
    nCups = await getNumberOfIconsFromConfig(widget.packPath);
    createFolder(widget.packPath);
    setState(() {});
  }

  void createFolder(String packPath) {
    Directory iconDir = Directory(path.join(packPath, 'Icons'));
    //if (iconDir.existsSync() && iconDir.listSync().isNotEmpty) return;

    if (!iconDir.existsSync()) {
      iconDir.createSync();
    }

    String iconDirPath = path.join(path.dirname(Platform.resolvedExecutable),
        "data", "flutter_assets", "assets", "images", "default_pack_icons");
    Directory assetIconsDir = Directory(iconDirPath);

    int i = -2;
    //print("test icon");
    //print(assetIconsDir.listSync());

    List<File> iconFileList =
        assetIconsDir.listSync().whereType<File>().toList();
    iconFileList.sort((a, b) => compareAlphamagically(a, b));
    for (File icon in iconFileList) {
      if (i >= nCups) return;
      if (!File(path.join(packPath, 'Icons', path.basename(icon.path)))
          .existsSync()) {
        icon.copySync(path.join(packPath, 'Icons', path.basename(icon.path)));
      }
      i++;
    }
    // File configFile = File("assets/config.txt");
    // configFile.copy(path.join(tmp.path, 'config.txt'));
  }

  @override
  Widget build(BuildContext context) {
    Process pr;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cup icons",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: nCups < 1
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Please create a valid track config first",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize),
                      )),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Put ',
                          style: TextStyle(
                              fontFamily: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.fontFamily,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.fontSize),
                          children: <TextSpan>[
                            TextSpan(
                                text: nCups.toString(),
                                style: const TextStyle(color: Colors.red)),
                            const TextSpan(
                              text: ' images in the Icons folder',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "The images has to be 128x128 and be named from 1.png to $nCups.png",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontSize),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 2.5),
                        child: ElevatedButton(
                          child: const Text(
                            "open Icons folder",
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () async => {
                            if (Directory(path.join(widget.packPath, 'Icons'))
                                .existsSync())
                              {
                                if (!Platform.isLinux)
                                  {
                                    launchUrlString(
                                        path.join(widget.packPath, 'Icons'))
                                  },
                                if (Platform.isLinux)
                                  {
                                    pr = await Process.start('open',
                                        [path.join(widget.packPath, 'Icons')]),
                                    await pr.exitCode,
                                    //await
                                  }
                              }
                          },
                        )),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: MediaQuery.of(context).size.width / 2.5),
                    //   child: ElevatedButton(
                    //       child: const Text(
                    //         "open Icons folder",
                    //         textAlign: TextAlign.center,
                    //       ),
                    //       onPressed: () => {
                    //             if (Directory(
                    //                     path.join(widget.packPath, 'Icons'))
                    //                 .existsSync())
                    //               launchUrlString(
                    //                   path.join(widget.packPath, 'Icons'))
                    //           }),
                    // ),
                  ]));
  }
}
