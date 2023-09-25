import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EasterEgg extends StatefulWidget {
  const EasterEgg({super.key});

  @override
  State<EasterEgg> createState() => _EasterEggState();
}

class _EasterEggState extends State<EasterEgg> {
  late SharedPreferences prefs;
  bool debugOn = false;
  @override
  initState() {
    super.initState();
    _init();
  }

  _init() async {
    prefs = await SharedPreferences.getInstance();
    debugOn = prefs.getBool('debug')!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Museo",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              FractionallySizedBox(
                widthFactor: 0.3,
                child: CheckboxListTile(
                    title: const Text("Debug Mode"),
                    fillColor: MaterialStateProperty.all<Color>(Colors.red),
                    value: debugOn,
                    onChanged: (value) async => {
                          debugOn = value!,
                          await prefs.setBool('debug', value),
                          setState(() {})
                        }),
              ),
              FractionallySizedBox(
                widthFactor: 0.85,
                child: Image.network(
                    fit: BoxFit.fitWidth,
                    'https://raw.githubusercontent.com/MatteoPrampolini/CTDM/images/quadro_bob.png'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  child: Image.network(
                      fit: BoxFit.fitWidth,
                      'https://raw.githubusercontent.com/MatteoPrampolini/CTDM/images/flamethrower.png'),
                ),
              )
            ]),
          ),
        ));
  }
}
