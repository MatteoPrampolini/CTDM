import 'dart:io';

import 'package:ctdm/drawer_options/gecko_codes.dart';
import 'package:ctdm/utils/gecko_utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

List<bool> generateSelectedOptions(
    List<Gecko> geckoListAll, List<Gecko> geckoListSelected) {
  List<bool> selectedOptions = List.filled(geckoListAll.length, false);

  // for (var gecko in geckoListSelected) {
  //   int index = geckoListAll.indexOf(gecko);
  //   if (index != -1) {
  //     selectedOptions[index] = true;
  //   }
  // }
  int index = 0;
  for (var gecko in geckoListAll) {
    if (geckoListSelected.contains(gecko)) {
      selectedOptions[index] = true;
    }
    index++;
  }
  return selectedOptions;
}

List<Gecko> updateGeckoListSelected(
    List<Gecko> geckoListAll, List<bool> selectedOptions) {
  List<Gecko> geckoListSelected = [];

  for (int i = 0; i < geckoListAll.length; i++) {
    if (selectedOptions[i]) {
      geckoListSelected.add(geckoListAll[i]);
    }
  }

  return geckoListSelected;
}

class SelectGecko extends StatefulWidget {
  final String packPath;
  const SelectGecko(this.packPath, {super.key});

  @override
  State<SelectGecko> createState() => _SelectGeckoState();
}

class _SelectGeckoState extends State<SelectGecko> {
  late List<Gecko> geckoListAll = getCodes();
  // ignore: prefer_final_fields
  late List<bool> _selectedOptions;

  @override
  void initState() {
    super.initState();
    copyGeckoAssetsToPack(widget.packPath);
  }

  List<Gecko> getCodes() {
    List<Gecko> tmp = List.from(
        Directory(path.join(widget.packPath, "..", "..", "myCodes"))
            .listSync()
            .whereType<File>()
            .map((e) => fileToGeckoCode(File(e.path))));
    tmp.sort(compareGecko);
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    //print(geckoList);
    geckoListAll = getCodes();
    late List<String> cheatsNameFromConfig =
        File(path.join(widget.packPath, 'gecko.txt')).readAsLinesSync();
    List<String> missingGecko = cheatsNameFromConfig
        .where((element) =>
            geckoListAll.map((e) => e.baseName).contains(element) == false)
        .toList();

    _selectedOptions = generateSelectedOptions(
        geckoListAll,
        parseGeckoTxt(
            widget.packPath, File(path.join(widget.packPath, 'gecko.txt'))));
    _selectedOptions[0] = true;
    _selectedOptions[1] = true;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gecko codes",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text("Select gecko codes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.fontSize)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: SizedBox(
                width: 600,
                child: Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(), color: Colors.red),
                        child: const ListTile(
                            title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                              Text("Name"),
                              Text("Enabled"),
                            ]))),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _selectedOptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.amberAccent,
                            ),
                            child: ListTile(
                              title: Text(
                                geckoListAll[index].name,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              trailing: Checkbox(
                                fillColor: MaterialStateColor.resolveWith(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.black54;
                                    }
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Colors.redAccent;
                                    }
                                    return Colors.redAccent.withOpacity(0.2);
                                  },
                                ),
                                side: const BorderSide(color: Colors.black87),
                                value: _selectedOptions[index],
                                onChanged: index < 2
                                    ? null
                                    : (value) => {
                                          if (index > 1)
                                            {
                                              _selectedOptions[index] = value!,
                                              writeGeckoTxt(
                                                  updateGeckoListSelected(
                                                      geckoListAll,
                                                      _selectedOptions),
                                                  File(path.join(
                                                      widget.packPath,
                                                      'gecko.txt'))),
                                              setState(() {})
                                            }
                                        },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: missingGecko.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.black,
                            ),
                            child: ListTile(
                              title: Text(
                                  '"${missingGecko[index]}" is in gecko.txt, but file was deleted.'),
                              trailing: const Icon(Icons.error),
                            ),
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextButton(
                            child: const Text("Code Manager"),
                            onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GeckoCodes(widget.packPath)))
                                .then((value) => setState(() => {}))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
