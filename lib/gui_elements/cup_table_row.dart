import 'dart:io';

import 'package:ctdm/gui_elements/types.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CupTableRow extends StatefulWidget {
  late Track track;
  late String packPath;
  late MaterialAccentColor color = Colors.amberAccent;
  CupTableRow(this.track, this.packPath, {super.key});

  @override
  State<CupTableRow> createState() => _CupTableRowState();
}

class _CupTableRowState extends State<CupTableRow> {
  late TextEditingController trackNameTextField;
  @override
  void initState() {
    switch (widget.track.type) {
      case TrackType.base:
        widget.color = Colors.amberAccent;
        break;
      case TrackType.menu:
        widget.color = Colors.cyanAccent;
        break;
      case TrackType.hidden:
        widget.color = Colors.limeAccent;
        break;
    }

    super.initState();
    trackNameTextField = TextEditingController();
    trackNameTextField.text = widget.track.name;
  }

  @override
  void dispose() {
    trackNameTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FilePickerResult? result;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black), color: widget.color),
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
                  child: TextField(
                    controller: trackNameTextField,
                    //widget.track.name,
                    style: const TextStyle(color: Colors.black87),
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
              child: Center(
                child: InkWell(
                  onTap: () => {print("hello")},
                  child: Text(
                    widget.track.slotId.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: InkWell(
                    onTap: () async => {
                      result = await FilePicker.platform.pickFiles(
                          allowedExtensions: ['szs'],
                          type: FileType.custom,
                          initialDirectory: path.join(
                              widget.packPath, '..', '..', 'MyTracks')),
                      if (result != null)
                        {
                          if (result?.files.single.path != null)
                            {
                              widget.track.path = path.basenameWithoutExtension(
                                  result?.files.single.path as String)
                            }
                        },
                      setState(() {}),
                    },
                    child: Text(
                      widget.track.path,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    widget.track.path,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
