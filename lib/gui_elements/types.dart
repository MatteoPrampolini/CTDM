import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum TrackType { base, menu, hidden }

class Track {
  late String name;
  late int slotId;
  late int musicId;
  late String path;
  late TrackType type;

  Track(this.name, this.slotId, this.musicId, this.path, this.type);
  @override
  String toString() {
    return "Track($path)";
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
