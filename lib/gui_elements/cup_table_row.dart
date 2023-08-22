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
    trackNameTextField.text = widget.track.name;
    musicslotTextField.text = widget.track.musicId.toString();
    trackslotTextField.text = widget.track.slotId.toString();
    //musicFolder = widget.track.musicFolder; // ?? "select music";
    musicFolder = widget.track.musicFolder;
    if (widget.track.musicFolder == null) musicFolder = "select music";
    //_selectedMusicOption = <bool>[true, false];

    trackNameTextField.text = widget.track.name;

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
                        flex: 7,
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
                                    //print("sono row: ${widget.rowIndex}"),
                                    //setState(() => {canDelete = !canDelete}),
                                    //print("row at:${widget.rowIndex}"),
                                    RowDeletePressed(
                                            widget.cupIndex, widget.rowIndex)
                                        .dispatch(context)
                                  },
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.redAccent)),
                        ),
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
                  onChanged: (value) => {
                    if (int.tryParse(value) == null)
                      {}
                    else
                      {
                        widget.track.slotId = int.tryParse(value)!,
                        RowChangedValue(
                                widget.track, widget.cupIndex, widget.rowIndex)
                            .dispatch(context)
                      }
                  },
                  style: const TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                    FilteringTextInputFormatter.allow(RegExp(r'[1-8]'))
                  ],
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
                              child: TextField(
                                controller: musicslotTextField,
                                onChanged: (value) => {
                                  if (int.tryParse(value) == null)
                                    {}
                                  else
                                    {
                                      widget.track.musicId =
                                          int.tryParse(value)!,
                                      RowChangedValue(widget.track,
                                              widget.cupIndex, widget.rowIndex)
                                          .dispatch(context)
                                    }
                                },
                                style: const TextStyle(color: Colors.black87),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[1-8]'))
                                ],
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
                                    allowedExtensions: ['mp3', 'wav', 'brstm'],
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
