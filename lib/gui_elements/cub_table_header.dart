import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CupTableHeader extends StatefulWidget {
  final int cupIndex;
  final String packPath;

  const CupTableHeader(this.cupIndex, this.packPath, {super.key});

  @override
  State<CupTableHeader> createState() => _CupTableHeaderState();
}

class _CupTableHeaderState extends State<CupTableHeader> {
  late bool canDelete = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.red, border: Border.all(color: Colors.black)),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Track Name",
                        style: TextStyle(color: Colors.black87),
                      ),
                      IconButton(
                          onPressed: () => {
                                setState(() => {canDelete = !canDelete})
                              },
                          icon: Icon(
                              canDelete ? Icons.delete_forever : Icons.delete))
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Center(
                child: Text("track slot",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     decoration:
          //         BoxDecoration(border: Border.all(color: Colors.black)),
          //     child: const Center(
          //       child: Text("music slot",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(color: Colors.black87)),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 3,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("File Path",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Music path",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Center(
                  child: File(path.join(widget.packPath, 'Icons',
                              '${widget.cupIndex}.png'))
                          .existsSync()
                      ? Image.file(File(path.join(
                          widget.packPath, 'Icons', '${widget.cupIndex}.png')))
                      : Text("${widget.cupIndex}.png"))),
        ],
      ),
    );
  }
}
