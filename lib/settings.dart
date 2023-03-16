import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences prefs;
  late String workspace = "";
  late int isoVersionNumber = 1;
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
              DropdownButton(
                value: isoVersionNumber,
                itemHeight: 50,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text("PAL"),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("USA"),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text("JAP"),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text("KOR"),
                  )
                ],
                onChanged: (value) {
                  isoVersionNumber = value!;

                  prefs.setString(
                      'isoVersion', VERSIONS.elementAt(isoVersionNumber));
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
