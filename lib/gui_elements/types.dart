import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum TrackType { base, menu, hidden }

class Track {
  late String name;
  late String slotId;
  late String musicId;
  late String path;
  late TrackType type;
  late String? musicFolder;
  late bool isNew;

  Track(this.name, this.slotId, this.musicId, this.path, this.type,
      [this.musicFolder, this.isNew = false]);
  @override
  String toString() {
    //return "Track($name)";
    if (musicFolder == null) {
      return "Track($name,$type)";
    }
    return "Track($name,$type,$musicFolder)";
  }
}

class Cup {
  late String cupName;
  List<Track> tracks;
  Cup(this.cupName, this.tracks);
  @override
  String toString() {
    return cupName;
  }
}

class AdjustableScrollController extends ScrollController {
  AdjustableScrollController([int extraScrollSpeed = 40]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(super.position.maxScrollExtent,
            max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }
}

class RowDeletePressed extends Notification {
  final int cupIndex;
  final int rowIndex;
  final int? nChildren;
  RowDeletePressed(this.cupIndex, this.rowIndex, [this.nChildren]);
}

class DeleteModeUpdated extends Notification {
  final bool shouldDelete;
  final int? destroyCupIndex;
  DeleteModeUpdated(this.shouldDelete, [this.destroyCupIndex]);
}

class RowChangedValue extends Notification {
  final int cupIndex;
  final int rowIndex;
  final Track track;
  RowChangedValue(this.track, this.cupIndex, this.rowIndex);
}

class CupNameChangedValue extends Notification {
  final int cupIndex;
  final String cupName;
  CupNameChangedValue(this.cupIndex, this.cupName);
}

class CupAskedToBeMoved extends Notification {
  final int cupIndex;
  final String cupName;
  final bool up;
  CupAskedToBeMoved(this.cupIndex, this.cupName, this.up);
}

class AddTrackRequest extends Notification {
  final TrackType type;
  final int cupIndex;
  final int? submenuIndex;
  AddTrackRequest(this.type, this.cupIndex, [this.submenuIndex]);
}
