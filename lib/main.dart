import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'pack_select.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  try {
    final _ = await Process.start('wlect', [], runInShell: false);

    prefs.setBool('szs', true);
  } on Exception catch (_) {
    //print("Wiimms' szs toolset not found");
    prefs.setBool('szs', false);
  }
  try {
    final _ = await Process.start('wit', [], runInShell: false);

    prefs.setBool('wit', true);
  } on Exception catch (_) {
    //print("Wiimms' wit toolset not found");
    prefs.setBool('wit', false);
  }
  try {
    final _ = await Process.start('ffmpeg', [], runInShell: false);

    prefs.setBool('ffmpeg', true);
  } on Exception catch (_) {
    //print("Wiimms' wit toolset not found");
    prefs.setBool('ffmpeg', false);
  }

  if (!prefs.containsKey('workspace')) {
    prefs.setString('workspace', '');
  }
  if (!prefs.containsKey('isoVersion')) {
    prefs.setString('isoVersion', 'PAL');
  }

  await DesktopWindow.setMinWindowSize(const Size(1000, 1000));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CTDM',
      theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          fontFamily: 'MarioMaker'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  final String title = 'CT Distribution Maker';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  late bool szsFound = false;
  late bool witFound = false;
  late bool ffmpegFound = false;
  late String workspace = "";
  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      szsFound = prefs.getBool('szs')!;
      workspace = prefs.getString('workspace')!;
      witFound = prefs.getBool('wit')!;
      ffmpegFound = prefs.getBool('ffmpeg')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.amber,
            actionsIconTheme:
                IconThemeData(color: Colors.red.shade700, size: 40),
            actions: [
              IconButton(
                  iconSize: 40,
                  alignment: Alignment.center,
                  tooltip: "Settings",
                  onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Settings()),
                        )
                      },
                  icon: const Icon(
                    Icons.settings_applications,
                  ))
            ],
            title: RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.fontFamily,
                        fontSize: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.fontSize),
                    text: 'CT Distribution ',
                    children: <TextSpan>[
                  TextSpan(
                      text: 'Maker',
                      style: TextStyle(color: Colors.red.shade700)),
                ]))),
        body: Center(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (workspace != "" && szsFound && witFound && ffmpegFound)
              const Expanded(
                child: PackSelect(),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!ffmpegFound)
                  Column(
                    children: [
                      Text(
                        "FFMPEG not installed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize,
                            color: Colors.white54),
                      ),
                      TextButton(
                        onPressed: () {
                          const url = 'https://ffmpeg.org/download.html';
                          final uri = Uri.parse(url);
                          launchUrl(uri);
                        },
                        child: Text(
                          "download",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            decoration: TextDecoration.underline,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (!szsFound)
                  Column(
                    children: [
                      Text(
                        "Wiimms SZS Toolset not installed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize,
                            color: Colors.white54),
                      ),
                      TextButton(
                        onPressed: () {
                          const url = 'https://szs.wiimm.de/';
                          final uri = Uri.parse(url);
                          launchUrl(uri);
                        },
                        child: Text(
                          "download",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            decoration: TextDecoration.underline,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize,
                          ),
                        ),
                      ),
                      if (witFound)
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            Platform.isWindows
                                ? "(Remember to reboot your PC after)"
                                : "",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                    ],
                  ),
                if (!witFound)
                  Padding(
                    padding: !szsFound
                        ? const EdgeInsets.all(20.0)
                        : const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Text(
                          "Wiimms ISO Tools not installed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.fontSize,
                              color: Colors.white54),
                        ),
                        TextButton(
                          onPressed: () {
                            const url = 'https://wit.wiimm.de/';
                            final uri = Uri.parse(url);
                            launchUrl(uri);
                          },
                          child: Text(
                            "download",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              decoration: TextDecoration.underline,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.fontSize,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            Platform.isWindows
                                ? "(Remember to reboot your PC after)"
                                : "",
                            style: const TextStyle(color: Colors.white54),
                          ),
                        )
                      ],
                    ),
                  ),
                if (workspace == "" && szsFound && witFound && ffmpegFound)
                  Column(
                    children: [
                      TextButton(
                          onPressed: () async {
                            String? result = await FilePicker.platform
                                .getDirectoryPath(lockParentWindow: true);
                            if (result != null) {
                              prefs.setString('workspace', result);
                              setState(() {
                                workspace = result;
                              });
                            }
                          },
                          child: Text(
                            "select a folder",
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.fontSize),
                          )),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          "Your packs and other stuff will be saved there.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
              ],
            )
          ],
        )));
  }
}
