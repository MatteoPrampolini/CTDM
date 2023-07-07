import 'dart:io';

import 'package:ctdm/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  late String workspace = "";
  late int isoVersionNumber = 1;
  // ignore: non_constant_identifier_names
  final List<String> VERSIONS = ["PAL", "USA", "JAP", "KOR"];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      workspace = prefs.getString('workspace')!;
      String? tmp = prefs.getString('isoVersion');
      if (tmp != null) {
        isoVersionNumber = VERSIONS.indexOf(tmp);
      }
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
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  "CTDM v0.8",
                  style: TextStyle(color: Colors.white54, fontSize: 20),
                ),
              ),
              SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => {
                      prefs.setString('workspace', ''),
                      setState(() {
                        workspace = '';
                      })
                    },
                    child: const Text(
                      "wipe",
                      style: TextStyle(fontSize: 30),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Workspace: ',
                    children: <TextSpan>[
                      TextSpan(
                          text: workspace,
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
              const FractionallySizedBox(widthFactor: 0.65, child: Divider()),
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
