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
  late String? musicFolder = widget.track.musicFolder ?? "select music";
  late TextEditingController musicslotTextField;

  late final List<bool> _selectedMusicOption =
      musicFolder == "select music" ? <bool>[false, true] : <bool>[true, false];
  @override
  void initState() {
    setColor();
    super.initState();
    trackNameTextField = TextEditingController();
    trackNameTextField.text = widget.track.name;
    trackslotTextField = TextEditingController();
    musicslotTextField = TextEditingController();
    musicslotTextField.text = widget.track.musicId.toString();
    trackslotTextField.text = widget.track.slotId.toString();
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
    widget.track.musicFolder != null
        ? musicFolder = widget.track.musicFolder
        : null;
    //trackslotTextField.text = widget.track.slotId.toString();
    setColor();
    FilePickerResult? result;
    FilePickerResult? musicRes;
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

                              //selectedBorderColor: Colors.redAccent,
                              //selectedColor: Colors.red[700],
                              //borderRadius: BorderRadius.circular(3),
                              fillColor: Colors.amber[200],
                              color: Colors.red[400],
                              onPressed: (index) => {
                                    for (int i = 0;
                                        i < _selectedMusicOption.length;
                                        i++)
                                      {
                                        _selectedMusicOption[i] = i == index,
                                        if (_selectedMusicOption[1])
                                          {
                                            //if number-> remove musicFolder
                                            widget.track.musicFolder = null,
                                            musicFolder = "select music",
                                          },
                                        setState(() => {}),
                                      }
                                  },
                              isSelected: _selectedMusicOption,
                              children: icons),
                        ),
                        Visibility(
                          visible: !_selectedMusicOption[0],
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
                          visible: _selectedMusicOption[0],
                          child: Expanded(
                            child: TextButton(
                              onPressed: () async => {
                                // musicFolder = await FilePicker.platform
                                //     .getDirectoryPath(
                                //         initialDirectory: path.dirname(
                                //             path.dirname(widget.packPath)),
                                //         dialogTitle: 'select music folder'),
                                musicRes = await FilePicker.platform.pickFiles(
                                    allowMultiple: false,
                                    allowedExtensions: ['mp3', 'wav'],
                                    type: FileType.custom,
                                    initialDirectory: path.join(widget.packPath,
                                        '..', '..', 'myMusic')),

                                musicFolder = musicRes?.paths[0],

                                if (musicFolder == null)
                                  {
                                    musicFolder = "select music",
                                  }
                                else
                                  {
                                    widget.track.musicFolder =
                                        path.basename(musicFolder!)
                                  },
                                RowChangedValue(widget.track, widget.cupIndex,
                                        widget.rowIndex)
                                    .dispatch(context),
                                setState(() => {})
                              },
                              child: Text(
                                path.basename(musicFolder!),
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
