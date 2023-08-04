// ignore_for_file: must_be_immutable

import 'package:ctdm/gui_elements/cup_table_row.dart';
import 'package:ctdm/gui_elements/cup_table_submenu.dart';
import 'package:ctdm/gui_elements/types.dart';

import 'package:flutter/material.dart';

import 'cub_table_header.dart';

class CupTable extends StatefulWidget {
  late int cupIndex;
  late String packPath;
  late List<Track> cup;
  late String cupName;
  late int iconIndex;
  late bool? isDisabled;
  CupTable(this.cupIndex, this.cupName, this.cup, this.packPath, this.iconIndex,
      {this.isDisabled, super.key});

  @override
  State<CupTable> createState() => _CupTableState();
}

class _CupTableState extends State<CupTable> {
  late bool canDelete = false;
  late TextEditingController cupNameTextField;
  @override
  void initState() {
    super.initState();
    cupNameTextField = TextEditingController();
    cupNameTextField.text = widget.cupName != ""
        ? widget.cupName.replaceAll(r'"', '')
        : "Cup #${widget.cupIndex}";
  }

  @override
  void dispose() {
    cupNameTextField.dispose();
    super.dispose();
  }

  int i = 0;
  bool changeDeleteMode(DeleteModeUpdated n) {
    canDelete = n.shouldDelete;
    setState(() {});
    if (n.destroyCupIndex != null && n.destroyCupIndex! > 0) {
      return false;
    } else {
      return true;
    }
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  int increaseCounter(int val, int howMuch) {
    i = val + howMuch;
    return val + 1;
  }

  @override
  Widget build(BuildContext context) {
    i = 0;
    return Padding(
        padding:
            const EdgeInsets.only(top: 40, bottom: 40, left: 100, right: 100),
        child: NotificationListener<DeleteModeUpdated>(
            onNotification: changeDeleteMode,
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: SizedBox(
                      width: 250,
                      child: TextField(
                        controller: cupNameTextField,
                        onChanged: (value) => {
                          widget.cupName = value,
                          CupNameChangedValue(widget.cupIndex, value)
                              .dispatch(context)
                        },
                      )),
                ),
              ),
              widget.isDisabled == true
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Colors.white70, BlendMode.color),
                      child: CupTableHeader(
                          widget.cupIndex, widget.packPath, widget.iconIndex),
                    )
                  : CupTableHeader(
                      widget.cupIndex, widget.packPath, widget.iconIndex),
              for (var track in widget.cup)
                track.type == TrackType.base
                    ? widget.isDisabled == true
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                                Colors.white24, BlendMode.color),
                            child: CupTableRow(track, widget.cupIndex,
                                i = i + 1, widget.packPath, canDelete),
                          )
                        : CupTableRow(track, widget.cupIndex, i = i + 1,
                            widget.packPath, canDelete)
                    : track.type == TrackType.menu
                        ? CupTableSubMenu(
                            [track]
                                .followedBy(
                                  widget.cup.sublist(i + 1).takeWhile((track) =>
                                      track.type != TrackType.base &&
                                      track.type != TrackType.menu),
                                )
                                .toList(),
                            widget.cupIndex,
                            i = i + 1,
                            widget.packPath,
                            canDelete)

                        // CupTableSubMenu(
                        //     widget.cup
                        //                 .getRange(
                        //                     widget.cup.indexOf(track),
                        //                     getLastHiddenIndexPlus1(
                        //                         widget.cup, track))
                        //                 .toList()
                        //                 .isEmpty ==
                        //             true
                        //         ? List.of([track])
                        //         : widget.cup
                        //             .getRange(
                        //                 widget.cup.indexOf(track),
                        //                 getLastHiddenIndexPlus1(
                        //                     widget.cup, track))
                        //             .toList(),
                        //     widget.cupIndex,
                        //     increaseCounter(
                        //         i,
                        //         widget.cup
                        //             .getRange(
                        //                 widget.cup.indexOf(track),
                        //                 widget.cup.indexOf(widget.cup
                        //                     .sublist(widget.cup.indexOf(track))
                        //                     .firstWhere(
                        //                         (element) =>
                        //                             element.type ==
                        //                             TrackType.base,
                        //                         orElse: () => track)))
                        //             .toList()
                        //             .length),
                        //     widget.packPath,
                        //     canDelete)
                        : Container(
                            child: (i = i + 1) > 0 ? null : Container(),
                          ),
              // : CupTableRow(track, widget.cupIndex, i = i + 1,
              //     widget.packPath, canDelete),
              Visibility(
                  visible: widget.cup
                          .where((element) => element.type != TrackType.hidden)
                          .length <
                      4,
                  child: SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          child: const Text("Add track"),
                          onPressed: () =>
                              AddTrackRequest(TrackType.base, widget.cupIndex)
                                  .dispatch(context),
                        ),
                        ElevatedButton(
                          child: const Text("Add menu"),
                          onPressed: () =>
                              AddTrackRequest(TrackType.menu, widget.cupIndex)
                                  .dispatch(context),
                        )
                      ],
                    ),
                  ))
            ])));
  }
}

int getLastHiddenIndexPlus1(List<Track> cup, Track track) {
  int end = cup.indexOf(cup.sublist(cup.indexOf(track)).firstWhere(
      (element) => element.type == TrackType.base,
      orElse: () => track));
  if (end == cup.indexOf(track)) end = cup.length;
  return end;
}
