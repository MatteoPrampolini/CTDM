//import 'dart:io';

// ignore_for_file: must_be_immutable

import 'package:ctdm/gui_elements/types.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class CupTableRow extends StatefulWidget {
  late Track track;
  late String packPath;
  late int cupIndex = -1;
  late int rowIndex = -1;
  late bool canDeleteTracks = false;
  late MaterialAccentColor color = Colors.purpleAccent;
  CupTableRow(this.track, this.cupIndex, this.rowIndex, this.packPath,
      this.canDeleteTracks,
      {super.key});

  @override
  State<CupTableRow> createState() => _CupTableRowState();
}

class _CupTableRowState extends State<CupTableRow> {
  late TextEditingController trackNameTextField;
  late TextEditingController trackslotTextField;
  late String? musicFolder;
  late TextEditingController musicslotTextField;
  String? errorTextTrackSlot;
  String? errorTextMusicslot;
  bool isNew = false;
  // ignore: prefer_final_fields
  //late List<bool> _selectedMusicOption;
  @override
  void initState() {
    //print(widget.track);

    setColor();
    super.initState();
    trackNameTextField = TextEditingController();

    trackslotTextField = TextEditingController();
    musicslotTextField = TextEditingController();
    musicFolder = widget.track.musicFolder ?? "select music";

    trackNameTextField.text = widget.track.name;
    musicslotTextField.text = widget.track.musicId.toString();
    trackslotTextField.text = widget.track.slotId.toString();
    isNew = widget.track.isNew;
    // _selectedMusicOption = musicFolder != "select music"
    //     ? <bool>[true, false]
    //     : <bool>[false, true];
    // setState(() => {});
  }

  void setColor() {
    switch (widget.track.type) {
      case TrackType.base:
        widget.color = Colors.amberAccent;
        break;
      case TrackType.menu:
        widget.color = Colors.limeAccent;
        break;
      case TrackType.hidden:
        widget.color = Colors.amberAccent;
        break;
    }
  }

  @override
  void dispose() {
    trackNameTextField.dispose();
    trackslotTextField.dispose();
    musicslotTextField.dispose();
    super.dispose();
  }

  List returnValues() {
    //widget.track.slotId=
    return [widget.track, musicFolder];
  }

  @override
  Widget build(BuildContext context) {
    musicFolder = widget.track.musicFolder; // ?? "select music";
    musicFolder = widget.track.musicFolder;
    if (widget.track.musicFolder == null) musicFolder = "select music";
    //_selectedMusicOption = <bool>[true, false];
    trackNameTextField.text = widget.track.name;
    if (errorTextMusicslot == null) {
      musicslotTextField.text = widget.track.musicId.toString();
    }
    if (errorTextTrackSlot == null) {
      trackslotTextField.text = widget.track.slotId.toString();
    }
    trackNameTextField.text = widget.track.name;

    // RegExp(r'^[1-8][1-4]$').hasMatch(widget.track.slotId.toString())
    //     ? ""
    //     : "error";
    setColor();
    FilePickerResult? result;
    FilePickerResult? musicRes;

    if (widget.track.musicFolder == "." ||
        widget.track.musicFolder == ".." ||
        widget.track.musicFolder == "myMusic") {
      musicFolder = "select music";
    }
    if (musicFolder == null) {
      musicFolder == "..TMP..";
    }

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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: trackNameTextField,
                          onChanged: (value) => {
                            widget.track.name = value,
                            RowChangedValue(widget.track, widget.cupIndex,
                                    widget.rowIndex)
                                .dispatch(context)
                          },
                          //widget.track.name,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Visibility(
                          visible: widget.canDeleteTracks == true,
                          child: IconButton(
                              onPressed: () => {
                                    RowDeletePressed(
                                            widget.cupIndex, widget.rowIndex)
                                        .dispatch(context)
                                  },
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.redAccent)),
                        ),
                      ),
                      Visibility(
                        visible: !widget.track.slotId.startsWith('A'),
                        child: Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () => {
                                      isNew = !isNew,
                                      widget.track.isNew = isNew,
                                      RowChangedValue(widget.track,
                                              widget.cupIndex, widget.rowIndex)
                                          .dispatch(context),
                                      setState(() {})
                                    },
                                icon: Icon(Icons.grade,
                                    color: isNew
                                        ? Colors.redAccent
                                        : Colors.white54))),
                      )
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
              child: Center(
                  child: TextField(
                controller: trackslotTextField,
                onChanged: (value) {
                  print(value);
                  RegExp regex = widget.cupIndex > 0
                      ? RegExp(r'^[1-8][1-4]$')
                      : RegExp(r'^A[1-2]?[1-5]?$');
                  if (regex.hasMatch(value)) {
                    widget.track.slotId = value;
                    RowChangedValue(
                            widget.track, widget.cupIndex, widget.rowIndex)
                        .dispatch(context);
                    setState(() {
                      errorTextTrackSlot = null;
                    });
                  } else {
                    setState(() {
                      errorTextTrackSlot = 'Invalid';
                    });
                  }
                },
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  errorText: errorTextTrackSlot,
                ),
              )),
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
                              widget.packPath, '..', '..', 'myTracks')),
                      if (result != null)
                        {
                          if (result?.files.single.path != null)
                            {
                              widget.track.path = path.basenameWithoutExtension(
                                  result?.files.single.path as String),
                              RowChangedValue(widget.track, widget.cupIndex,
                                      widget.rowIndex)
                                  .dispatch(context)
                            }
                        }
                      else
                        {
                          if (widget.cupIndex < 0)
                            {widget.track.path = "original file"}
                        },
                      setState(() {}),
                    },
                    child: Text(
                      widget.track.path,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
                  child: SizedBox(
                    width: 300.0,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.red)),
                          child: ToggleButtons(
                            fillColor: Colors.amber[200],
                            color: Colors.red[400],
                            isSelected: [
                              widget.track.musicFolder != null,
                              widget.track.musicFolder == null,
                            ],
                            onPressed: (index) {
                              setState(() {
                                if (index == 0) {
                                  // Se il pulsante "Folder" è selezionato
                                  widget.track.musicFolder = path.relative(
                                    path.join(
                                        widget.packPath, '..', '..', 'myMusic'),
                                    from: musicFolder,
                                  );

                                  //   if (widget.track.musicFolder == "." ||
                                  //       widget.track.musicFolder == ".." ||
                                  //       widget.track.musicFolder == "myMusic") {
                                  //     musicFolder = "..TMP..";
                                  //     widget.track.musicFolder = null;
                                  //   }
                                } else {
                                  // Se il pulsante "Select Music" è selezionato
                                  widget.track.musicFolder = null;

                                  // musicslotTextField.text =
                                  //     widget.track.musicId.toString();
                                }
                              });

                              RowChangedValue(widget.track, widget.cupIndex,
                                      widget.rowIndex)
                                  .dispatch(context);

                              setState(() {});
                            },
                            children: icons,
                          ),
                        ),
                        Visibility(
                          visible: widget.track.musicFolder == null,
                          child: Expanded(
                            child: Center(
                              child: TextFormField(
                                controller: musicslotTextField,
                                onChanged: (value) {
                                  if (isValidMusicSlot(value)) {
                                    widget.track.musicId = value;
                                    RowChangedValue(widget.track,
                                            widget.cupIndex, widget.rowIndex)
                                        .dispatch(context);

                                    setState(() {
                                      errorTextMusicslot = null;
                                    });
                                  } else {
                                    setState(() {
                                      errorTextMusicslot = 'Invalid';
                                    });
                                  }
                                },
                                style: const TextStyle(color: Colors.black87),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                decoration: InputDecoration(
                                  errorText:
                                      errorTextMusicslot, // Visualizza il messaggio di errore qui
                                  // Altri attributi di decorazione del campo
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.track.musicFolder != null ||
                              musicFolder == "..TMP..",
                          child: Expanded(
                            flex: 1,
                            child: TextButton(
                              onPressed: () async {
                                musicRes = await FilePicker.platform.pickFiles(
                                    allowMultiple: false,
                                    allowedExtensions: ['brstm'],
                                    type: FileType.custom,
                                    initialDirectory: path.join(widget.packPath,
                                        '..', '..', 'myMusic'));
                                musicFolder = musicRes?.paths[0];

                                if (musicFolder == null) {
                                  musicFolder = null;
                                  widget.track.musicFolder =
                                      null; // Assegna null a widget.track.musicFolder
                                } else {
                                  // Rimuovi eventuali occorrenze di '..' dal percorso
                                  musicFolder = musicFolder?.replaceAll(
                                      RegExp(r'\.\.'), '');

                                  widget.track.musicFolder =
                                      musicFolder?.replaceFirst(
                                          RegExp(r'^.*[\\,\/]myMusic*.'), '');

                                  //musicFolder = widget.track.musicFolder;
                                }
                                // ignore: use_build_context_synchronously
                                RowChangedValue(widget.track, widget.cupIndex,
                                        widget.rowIndex)
                                    .dispatch(context);
                                setState(() {});
                              },
                              child: Text(
                                path.basename(musicFolder!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

const List<Widget> icons = <Widget>[
  Icon(
    Icons.folder,
    size: 25,
  ),
  Icon(
    Icons.pin,
    size: 25,
  )
];

bool isValidMusicSlot(String text) {
  if (text.length < 2 || text.length > 3) return false;

  //Arena
  if (text.length == 3) {
    if (text.characters.elementAt(0) != "A" &&
        text.characters.elementAt(0) != "a") {
      return false;
    }
    if (!RegExp(r'[1-2]').hasMatch(text.characters.elementAt(1))) {
      return false;
    }
    if (!RegExp(r'[1-5]').hasMatch(text.characters.elementAt(2))) {
      return false;
    }
    return true;
  }
  //Normal
  if (!RegExp(r'[1-8]').hasMatch(text.characters.elementAt(0))) {
    return false;
  }
  if (!RegExp(r'[1-4]').hasMatch(text.characters.elementAt(1))) {
    return false;
  }
  return true;
}
