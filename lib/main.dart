import 'package:ctdm/utils/exceptions_utils.dart';
import 'package:ctdm/utils/log_utils.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'pack_select.dart';
import 'settings.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runZonedGuarded(() => _main(), (error, stackTrace) {
    if (error.runtimeType != CtdmException) {
      error = CtdmException(null, stackTrace, "0000");
    }

    logString(LogType.ERROR, error.toString());
    logString(LogType.ERROR, stackTrace.toString());

    runApp(NotifyErrorWidget(
        error: error as CtdmException,
        stacktrace: stackTrace.toString(),
        jsonStringPath: path.join(path.dirname(Platform.resolvedExecutable),
            "data", "flutter_assets", "assets", "errors.json")));
  });
}

class NotifyErrorWidget extends StatelessWidget {
  final CtdmException error;
  final String stacktrace;
  final String jsonStringPath;
  const NotifyErrorWidget(
      {super.key,
      required this.error,
      required this.stacktrace,
      required this.jsonStringPath});

  @override
  Widget build(BuildContext context) {
    String jsonString = File(jsonStringPath).readAsStringSync();
    CtdmError? ctdmError = error.getDetailedError(jsonString);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CTDM',
      theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
          fontFamily: 'MarioMaker'),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          actionsIconTheme: IconThemeData(color: Colors.red.shade700, size: 40),
          iconTheme: IconThemeData(
            color: Colors.red.shade700, //change your color here
          ),
          title: const Text('CTDM error page',
              style: TextStyle(color: Colors.black87)),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 100.0, bottom: 120),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/error_mario.webp',
                  scale: 1.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "AN ERROR OCCURRED",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            backgroundColor: Colors.red,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.fontSize),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, left: 20),
                      child: Text(
                        "What happened:",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.fontSize),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5),
                      child: Text(
                        error.details != null
                            ? error.details!
                            : "Details unknown",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0, left: 20),
                      child: Text(
                        "Error:",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            const Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              ctdmError.description,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            const Text(
                              "Code: ",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              ctdmError.errorCode,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0, left: 20),
                      child: Text(
                        "Stacktrace:",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.redAccent)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                                //scrollDirection: Axis.horizontal,
                                child: Text(
                              overflow: TextOverflow.clip,
                              stacktrace,
                              style: const TextStyle(color: Colors.white54),
                            )),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.black12,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              'Check the "log.log" file inside your workspace.',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: 400,
                              child: ElevatedButton(
                                  style: const ButtonStyle(
                                      fixedSize: MaterialStatePropertyAll(
                                          Size(350, 40))),
                                  onPressed: () => {main()},
                                  child: const Text("Restart CTDM")),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> checkForUpdates(String version) async {
  String currentVersion = version;

  String owner = 'MatteoPrampolini';
  String repository = 'CTDM';
  String apiUrl = 'https://api.github.com/repos/$owner/$repository/releases';

  try {
    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> releases = json.decode(response.body);

      String latestVersion =
          releases.isNotEmpty ? releases[0]['tag_name'] : null;

      if (compareVersions(latestVersion, currentVersion) > 0) {
        return latestVersion;
      }
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
  return null;
}

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('version', 'v0.9.14');
  await prefs.setBool('download_already_check', false);

  try {
    ProcessResult p =
        await Process.run('wlect', ['--version'], runInShell: true);
    if (p.exitCode == 1) {
      //error in executing wlect --version
      prefs.setBool('szs', false);
      logString(LogType.ERROR, "Wiimms' szs toolset not found.");
    } else {
      double version = double.parse(p.stdout
          .toString()
          .split(RegExp(r'LE-CODE Tool v'))[1]
          .substring(0, 4));
      if (version < 2.33) {
        //https://szs.wiimm.de/changelog.html
        //2.36 when --9-laps will be implemented.

        prefs.setBool('szs', false);
        logString(LogType.ERROR,
            "Wiimms' szs toolset version too old. Please update.");
      } else {
        prefs.setBool('szs', true);
      }
    }
  } on Exception catch (_) {
    //(there is no whay this expection will be thrown)

    //print("Wiimms' szs toolset not found");
    prefs.setBool('szs', false);
    logString(LogType.ERROR, "Wiimms' szs toolset not found?");
  }

  try {
    final _ = await Process.start('wit', [], runInShell: false);

    prefs.setBool('wit', true);
  } on Exception catch (_) {
    //print("Wiimms' wit toolset not found");
    logString(LogType.ERROR, "Wiimms' wit toolset not found");
    prefs.setBool('wit', false);
  }

  // defaultSettingsValues.remove('dolphin');
  defaultSettingsValues.forEach((key, value) async {
    if (!prefs.containsKey(key)) {
      if (['debug'].contains(key)) {
        await prefs.setBool(key, value);
      } else {
        await prefs.setString(key, value);
      }
    }
  });
  // //await DesktopWindow.setMinWindowSize(const Size(1300, 800));
  // double devicePixelRatio = MediaQueryData.fromView(WidgetsBinding.instance.window).devicePixelRatio;
  // DesktopWindow.setMinWindowSize(
  //     Size(1300 * devicePixelRatio, 800 * devicePixelRatio));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //await DesktopWindow.setMinWindowSize(const Size(1300, 800));
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DesktopWindow.setMinWindowSize(
        Size(935 * devicePixelRatio, 720 * devicePixelRatio),
      );
    });
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

void showUpdateAlert(BuildContext context, String newVersion) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Update Available"),
      content:
          const Text("A new version is available. Do you want to update now?"),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Chiudi il dialog
            // Azione da eseguire se l'utente sceglie di non aggiornare
          },
          child: const Text('Ignore'),
        ),
        TextButton(
          onPressed: () {
            final uri = Uri.parse(
                'https://github.com/MatteoPrampolini/CTDM/releases/tag/$newVersion');
            launchUrl(uri);
            //Navigator.pop(context);
            //urlLa // Chiudi il dialog
            // Azione da eseguire se l'utente sceglie di aggiornare
            // Esempio: apri un link alla pagina delle release su GitHub
            // launch('URL DELLA PAGINA DELLE RELEASE');
          },
          style: TextButton.styleFrom(
            foregroundColor:
                Colors.amberAccent, // Cambia il colore del testo a blu
          ),
          child: const Text(
            'Update',
          ),
        ),
      ],
    ),
  );
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
      if (workspace != '' && !Directory(workspace).existsSync()) {
        workspace = '';
      }
      witFound = prefs.getBool('wit')!;
    });
    String version = prefs.getString('version')!;

    String? newVersion = await checkForUpdates(version);
    bool alreadyAsked = prefs.getBool('download_already_check')!;
    if (newVersion != null && !alreadyAsked) {
      // ignore: use_build_context_synchronously
      showUpdateAlert(context, newVersion);
    }
    await prefs.setBool('download_already_check', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.amber,
            actionsIconTheme:
                IconThemeData(color: Colors.red.shade700, size: 40),
            iconTheme: IconThemeData(
              color: Colors.red.shade700, //change your color here
            ),
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
                        ).then((value) => {loadSettings(), setState(() => {})})
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
            if (workspace != "" && szsFound && witFound)
              const Expanded(
                child: PackSelect(),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!szsFound)
                  Column(
                    children: [
                      Text(
                        "Wiimms SZS Toolset not installed or obsolete.",
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
                          "download latest",
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
                            "download latest",
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
                if (workspace == "" && szsFound && witFound)
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

String addNewLinesEveryNCharacters(String input, int n) {
  StringBuffer output = StringBuffer();
  int length = input.length;

  for (int i = 0; i < length; i += n) {
    int end = i + n;
    if (end > length) {
      end = length;
    }
    output.write(input.substring(i, end));
    if (end < length) {
      output.writeln();
    }
  }

  return output.toString();
}

int compareVersions(String version1, String version2) {
  List<String> v1Components = version1.split('.');
  List<String> v2Components = version2.split('.');

  for (int i = 0; i < v1Components.length && i < v2Components.length; i++) {
    String v1 = v1Components[i];
    String v2 = v2Components[i];

    int numericComparison = _compareNumericComponents(v1, v2);
    if (numericComparison != 0) {
      return numericComparison;
    }

    int alphaComparison = _compareAlphaComponents(v1, v2);
    if (alphaComparison != 0) {
      return alphaComparison;
    }
  }

  return v1Components.length - v2Components.length;
}

int _compareNumericComponents(String v1, String v2) {
  int numeric1 = int.tryParse(v1) ?? 0;
  int numeric2 = int.tryParse(v2) ?? 0;

  if (numeric1 < numeric2) {
    return -1;
  } else if (numeric1 > numeric2) {
    return 1;
  } else {
    return 0;
  }
}

int _compareAlphaComponents(String v1, String v2) {
  // // Estrai la parte alfanumerica da entrambe le componenti
  // String alpha1 = v1.replaceAll(RegExp(r'[0-9]'), '');
  // String alpha2 = v2.replaceAll(RegExp(r'[0-9]'), '');

  return v1.compareTo(v2);
}
