import 'dart:io';

import 'package:ctdm/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  String workspace = "";
  late String version = "";
  String riivolution = "";
  String dolphin = "";
  String game = "";
  //late int isoVersionNumber = 1;
  // ignore: non_constant_identifier_names
  //final List<String> VERSIONS = ["PAL", "USA", "JAP", "KOR"];

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();

    version = prefs.getString("version")!;

    setState(() {
      workspace = prefs.getString('workspace')!;
      riivolution = prefs.getString('Riivolution')!;
      dolphin = prefs.getString('dolphin')!;
      game = prefs.getString('game')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (workspace != "" && Directory(workspace).existsSync()) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
              } else {
                Navigator.pop(context);
              }
            }),
        iconTheme: IconThemeData(
          color: Colors.red.shade700, //change your color here
        ),
        backgroundColor: Colors.amber,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "CTDM $version",
                  style: const TextStyle(color: Colors.white54, fontSize: 20),
                ),
              ),
              SettingOptionFolder(
                'Workspace:',
                Directory(workspace),
                false,
                'workspace',
                loadSettings,
              ),
              // SettingOptionFolder('Riivolution:', Directory(riivolution),
              //     'Riivolution', loadSettings),
              Platform.isWindows
                  ? SettingOptionFolder(
                      'Dolphin executable:',
                      Directory(dolphin),
                      true,
                      'dolphin',
                      loadSettings,
                      extensions: const ['exe'],
                    )
                  : SettingOptionFolder('Dolphin executable:',
                      Directory(dolphin), true, 'dolphin', loadSettings),
              SettingOptionFolder(
                  'Game ISO:', Directory(game), true, 'game', loadSettings,
                  extensions: const ['iso', 'wbfs']),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SizedBox(
                    width: 320,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => {
                        prefs.setString('workspace', ''),
                        setState(() {
                          workspace = '';
                        })
                      },
                      child: const Text(
                        "reset settings",
                        style: TextStyle(fontSize: 24),
                      ),
                    )),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child:
                    FractionallySizedBox(widthFactor: 0.65, child: Divider()),
              ),
              Card(
                child: FractionallySizedBox(
                  widthFactor: 0.65,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("Need help?"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SocialCard(Icons.discord, "Discord",
                                  Uri.parse("https://discord.gg/DFTnFMreAT")),
                              SocialCard(
                                  Icons.code,
                                  "Github",
                                  Uri.parse(
                                      "https://github.com/MatteoPrampolini/CTDM")),
                              SocialCard(
                                  Icons.menu_book,
                                  "Tockdom wiki",
                                  Uri.parse(
                                      "https://wiki.tockdom.com/wiki/Custom_Track_Distribution_Maker"))
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SocialCard extends StatelessWidget {
  IconData icon;
  String text;
  Uri url;
  SocialCard(this.icon, this.text, this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 120,
      child: Column(
        children: [
          IconButton(
            iconSize: 80,
            color: Colors.amberAccent,
            onPressed: () => _launchUrl(url),
            icon: Icon(
              icon,
              //size: 80,
              //color: Colors.amberAccent,
            ),
          ),
          Text(text)
        ],
      ),
    );
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

// ignore: must_be_immutable
class SettingOptionFolder extends StatefulWidget {
  String text;
  FileSystemEntity fileSystemEntity;
  String settingKey;
  Function reloadParent;
  bool isFile;
  List<String>? extensions;

  SettingOptionFolder(
    this.text,
    this.fileSystemEntity,
    this.isFile,
    this.settingKey,
    this.reloadParent, {
    this.extensions,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingOptionFolder> createState() => _SettingOptionFolderState();
}

class _SettingOptionFolderState extends State<SettingOptionFolder> {
  @override
  @override
  Widget build(BuildContext context) {
    String? selectedDir;
    FilePickerResult? tmp;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 6),
      child: IntrinsicHeight(
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
              flex: 4,
              child: Text(
                widget.text,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
              )),
          Expanded(
            flex: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                    widget.fileSystemEntity.path.isNotEmpty
                        ? widget.fileSystemEntity.path
                        : '---',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 16)),
              ),
            ),
          ),
          Expanded(
              flex: 4,
              child: ElevatedButton(
                  style: TextButton.styleFrom(
                      fixedSize: const Size.fromHeight(36)),
                  onPressed: () async => {
                        if (widget.isFile)
                          {
                            if (widget.extensions == null)
                              {
                                tmp = (await FilePicker.platform.pickFiles(
                                    type: FileType.any, lockParentWindow: true))
                              }
                            else
                              {
                                tmp = (await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: widget.extensions,
                                    lockParentWindow: true))
                              },
                            selectedDir =
                                tmp == null ? "" : tmp!.files.first.path
                          }
                        else
                          {
                            selectedDir =
                                await FilePicker.platform.getDirectoryPath()
                          },
                        if (selectedDir != null)
                          {
                            await (await SharedPreferences.getInstance())
                                .setString(widget.settingKey, selectedDir!),
                            widget.reloadParent()
                          }
                      },
                  child: const FittedBox(
                    child: Text(
                      "Select",
                      textAlign: TextAlign.center,
                    ),
                  ))),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  shape: BoxShape.rectangle,
                ),
                child: FittedBox(
                  child: IconButton(
                    splashRadius: 20,
                    tooltip: "reset to default",
                    icon: const Icon(Icons.restart_alt),
                    onPressed: () async => {
                      await (await SharedPreferences.getInstance()).setString(
                          widget.settingKey,
                          defaultSettingsValues[widget.settingKey]!),
                      widget.reloadParent()
                    },
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

Map<String, String> defaultSettingsValues = {
  'workspace': '',
  'Riivolution': getDeafultRiivoFolder(),
  'dolphin':
      '', //TODO chiamare dolphin.exe sul cmd e vedere se esiste nel path. ha senso visto che di default non viene aggiunto?
  'game': '',
};

String getDeafultRiivoFolder() {
  String returnPath = '';
  if (Platform.isWindows) {
    String user =
        Process.runSync('whoami', []).stdout.toString().split(r'\')[1].trim();

    returnPath = path.join('C:', 'Users', user, 'Documents', 'Dolphin Emulator',
        'Load', 'Riivolution');
  }

  if (Platform.isLinux) {
    String user = Process.runSync('whoami', []).stdout.toString().trim();
    returnPath = path.join('/', 'home', user, '.local', 'share', 'dolphin-emu',
        'Load', 'Riivolution');
  }
  //TODO MAC  OSX
  if (Platform.isMacOS) {}

  return returnPath;
}
