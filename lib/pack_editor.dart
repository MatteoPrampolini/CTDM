import 'dart:io';

import 'package:ctdm/custom_drawer.dart';
import 'package:ctdm/patch_window.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PackEditor extends StatefulWidget {
  final String packPath;
  const PackEditor(this.packPath, {super.key});

  @override
  State<PackEditor> createState() => _PackEditorState();
}

class _PackEditorState extends State<PackEditor> {
  late bool checkResultVisibility = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late bool canPatch = false;
  late List<bool> checks = [false, false, false, false, false, false];
  final int optIndex = 3;
  final List<String> steps = [
    "valid pack name",
    'track config',
    'lpar config',
    'gecko codes',
    'custom character',
    'online patch'
  ];
  void checkEverything() {
    checks[0] = !widget.packPath.contains('tmp_pack_');
    checks[1] = File(path.join(widget.packPath, 'config.txt')).existsSync();
    checks[2] = File(path.join(widget.packPath, 'lpar.txt')).existsSync();

    canPatch = checks.take(optIndex).every((element) => element == true);
    if (!checkResultVisibility && !canPatch) {
      checkResultVisibility = true;
      Future.delayed(const Duration(seconds: 5), () {
        //asynchronous delay
        if (mounted) {
          //checks if widget is still active and not disposed
//tells the widget builder to rebuild again because ui has updated
          setState(() => {checkResultVisibility = false});
          //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
        }
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    loadSettings();
    super.initState();
  }

  void loadSettings() async {
    if (!await Directory(path.join(widget.packPath, 'Scene')).exists()) {
      Directory(path.join(widget.packPath, 'Scene')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'sys')).exists()) {
      Directory(path.join(widget.packPath, 'sys')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'rel')).exists()) {
      Directory(path.join(widget.packPath, 'rel')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race')).exists()) {
      Directory(path.join(widget.packPath, 'Race')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race', 'Course'))
        .exists()) {
      Directory(path.join(widget.packPath, 'Race', 'Course')).create();
    }
    if (!await Directory(path.join(widget.packPath, 'Race', 'Common'))
        .exists()) {
      Directory(path.join(widget.packPath, 'Race', 'Common')).create();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(widget.packPath),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.red.shade700, //change your color here
        ),
        backgroundColor: Colors.amber,
        title: Text(
          'Pack Editor ${path.basename(widget.packPath)}',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Automatic Check List",
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.headline4?.fontSize)),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GridView.count(
                        crossAxisCount: 1,
                        shrinkWrap: true,
                        childAspectRatio: 1 / 0.09,
                        children: <Widget>[
                          for (var step in steps)
                            ListTile(
                              onTap: null,
                              enabled: checks[steps.indexOf(step)],
                              title: Text(step),
                              trailing: steps.indexOf(step) >= optIndex
                                  ? const Text(
                                      "[opt]",
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : null,
                              leading: Checkbox(
                                splashRadius: 0,
                                value: checks[steps.indexOf(step)],
                                activeColor: Colors.amberAccent,
                                fillColor: MaterialStateProperty.all(
                                    Colors.amberAccent),
                                side: const BorderSide(
                                    color: Colors.white38, width: 2),
                                onChanged: null,
                              ),
                            )
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () => {
                                    //_scaffoldKey.currentState?.openDrawer(),
                                    checkEverything(),
                                    if (!canPatch)
                                      {
                                        Future.delayed(
                                            const Duration(seconds: 2), () {
                                          //asynchronous delay
                                          if (mounted) {
                                            //checks if widget is still active and not disposed
//tells the widget builder to rebuild again because ui has updated
                                            _scaffoldKey.currentState
                                                ?.openDrawer();
                                            //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
                                          }
                                        })
                                      }
                                  },
                              child: const Text("CHECK")),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent),
                              onPressed: canPatch
                                  ? () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PatchWindow(
                                                        widget.packPath)))
                                      }
                                  : null,
                              child: Text("PATCH!",
                                  style: TextStyle(
                                      color: canPatch
                                          ? Colors.black
                                          : Colors.white)),
                            )),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Visibility(
                        visible: checkResultVisibility,
                        child: const Text(
                          "Failed: complete mandatory steps first.",
                          style: TextStyle(color: Colors.white60),
                        )),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
