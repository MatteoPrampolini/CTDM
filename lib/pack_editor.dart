import 'package:ctdm/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PackEditor extends StatefulWidget {
  final String packPath;
  const PackEditor(this.packPath, {super.key});

  @override
  State<PackEditor> createState() => _PackEditorState();
}

class _PackEditorState extends State<PackEditor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //late TextEditingController _noteController;
  late bool validName = false;
  @override
  void initState() {
    super.initState();
    // _noteController = TextEditingController.fromValue(
    //   TextEditingValue(
    //     text: path.basename(widget.packPath),
    //   ),
    // );
  }

  @override
  void dispose() {
    //_noteController.dispose();
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
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    title: const Text("valid name and id"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    title: const Text("tracks config"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    title: const Text("lpar"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    secondary: const Text(
                      "[opt]",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    title: const Text("gecko codes"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    secondary: const Text(
                      "[opt]",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    title: const Text("custom characters"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.amberAccent,
                    value: validName,
                    onChanged: (value) => {
                      setState(() => {validName = value!})
                    },
                    secondary: const Text(
                      "[opt]",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    title: const Text("online patch"),
                    controlAffinity: ListTileControlAffinity.leading,
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
                                    print("check")
                                  },
                              child: const Text("CHECK")),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: null, child: Text("PATCH!")),
                        ),
                      ),
                    ],
                  )

                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width / 2,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Tooltip(
                  //         message: "Pack name",
                  //         child: TextField(
                  //             decoration:
                  //                 const InputDecoration(border: InputBorder.none),
                  //             autofocus: false,
                  //             keyboardType: TextInputType.multiline,
                  //             maxLines: null,
                  //             controller: _noteController),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          )),
    );
  }
}
