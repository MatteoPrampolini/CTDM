import 'package:ctdm/gui_elements/cup_table_row.dart';
import 'package:ctdm/gui_elements/types.dart';
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
  bool changeDeleteMode(DeleteModeUpdated n) {
    canDelete = n.shouldDelete;
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Padding(
        padding:
            const EdgeInsets.only(top: 40, bottom: 40, left: 100, right: 100),
        child: NotificationListener<DeleteModeUpdated>(
            onNotification: changeDeleteMode,
            child: Column(children: [
              CupTableHeader(widget.cupIndex, widget.packPath),
              for (var track in widget.cup
                  .where((element) => element.type == TrackType.base))
                CupTableRow(track, widget.cupIndex, i = i + 1, widget.packPath,
                    canDelete),
              Visibility(
                  visible:
                      widget.cup.length < 4, //TODO FIXARE QUANDO SI USA MENU
                  child: SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          child: Text("Add track"),
                          onPressed: () =>
                              AddTrackRequest(TrackType.base, widget.cupIndex)
                                  .dispatch(context),
                        ),
                        ElevatedButton(
                          child: Text("Add menu"),
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
