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
  CupTable(this.cupIndex, this.cup, this.packPath, {super.key});

  @override
  State<CupTable> createState() => _CupTableState();
}

class _CupTableState extends State<CupTable> {
  late bool canDelete = false;
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

  void askChildForValues() {}
  @override
  Widget build(BuildContext context) {
    i = 0;
    return Padding(
        padding:
            const EdgeInsets.only(top: 40, bottom: 40, left: 100, right: 100),
        child: NotificationListener<DeleteModeUpdated>(
            onNotification: changeDeleteMode,
            child: Column(children: [
              CupTableHeader(widget.cupIndex, widget.packPath),
              for (var track in widget.cup)
                track.type == TrackType.base
                    ? CupTableRow(track, widget.cupIndex, i = i + 1,
                        widget.packPath, canDelete)
                    : track.type == TrackType.menu
                        ? CupTableSubMenu(
                            widget.cup
                                        .getRange(
                                            widget.cup.indexOf(track),
                                            getLastHiddenIndexPlus1(
                                                widget.cup, track))
                                        .toList()
                                        .isEmpty ==
                                    true
                                ? List.of([track])
                                : widget.cup
                                    .getRange(
                                        widget.cup.indexOf(track),
                                        getLastHiddenIndexPlus1(
                                            widget.cup, track))
                                    .toList(),
                            widget.cupIndex,
                            increaseCounter(
                                i,
                                widget.cup
                                    .getRange(
                                        widget.cup.indexOf(track),
                                        widget.cup.indexOf(widget.cup
                                            .sublist(widget.cup.indexOf(track))
                                            .firstWhere(
                                                (element) =>
                                                    element.type ==
                                                    TrackType.base,
                                                orElse: () => track)))
                                    .toList()
                                    .length),
                            widget.packPath,
                            canDelete)
                        : Container(),
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
