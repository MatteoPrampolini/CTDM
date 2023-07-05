//import 'dart:io';

// ignore_for_file: must_be_immutable

import 'package:ctdm/gui_elements/types.dart';
import 'package:flutter/material.dart';
//import 'package:path/path.dart' as path;

import 'cup_table_row.dart';

class CupTableSubMenu extends StatefulWidget {
  late List<Track> tracks;
  late String packPath;
  late int cupIndex = -1;
  late int rowIndex = -1;
  late bool canDeleteTracks = false;
  late MaterialAccentColor color = Colors.limeAccent;

  CupTableSubMenu(this.tracks, this.cupIndex, this.rowIndex, this.packPath,
      this.canDeleteTracks,
      {super.key});

  @override
  State<CupTableSubMenu> createState() => _CupTableSubMenuState();
}

class _CupTableSubMenuState extends State<CupTableSubMenu> {
  late TextEditingController trackNameTextField;
  late bool expanded = false;
  @override
  void initState() {
    widget.color = Colors.limeAccent;

    super.initState();
    trackNameTextField = TextEditingController();
    trackNameTextField.text = widget.tracks[0].name;
  }

  @override
  void dispose() {
    trackNameTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("submenu dice:${widget.tracks}");
    int i = widget.rowIndex;
    trackNameTextField.text = widget.tracks[0].name;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black), color: widget.color),
      child: Column(
        children: [
          SizedBox(
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
                                  widget.tracks[0].name = value,
                                  RowChangedValue(widget.tracks[0],
                                          widget.cupIndex, widget.rowIndex)
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
                                          RowDeletePressed(
                                                  widget.cupIndex,
                                                  widget.rowIndex,
                                                  widget.tracks.length)
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
                    child: const Center(
                      child: Text(
                        "", //widget.track.slotId.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Center(
                      child: InkWell(
                        onTap: () => {setState(() => expanded = !expanded)},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "SHOW HIDDEN TRACKS", //widget.track.slotId.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            IconButton(
                                onPressed: () =>
                                    {setState(() => expanded = !expanded)},
                                icon: const Icon(
                                  Icons.expand_more,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
              visible: expanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Column(
                  children: [
                    for (var track in widget.tracks.sublist(1))
                      CupTableRow(track, widget.cupIndex, i = i + 1,
                          widget.packPath, widget.canDeleteTracks),
                    ElevatedButton(
                      child: const Text("Add hidden"),
                      onPressed: () => AddTrackRequest(TrackType.hidden,
                              widget.cupIndex, widget.rowIndex)
                          .dispatch(
                              context), //aggiungere parametro che indica last index delle hidden track, credo sia semplicemente i?
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
