import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

//taken from https://pub.dev/packages/merge_images
ui.Image margeImages(List<ui.Image> imageList,
    {Axis direction = Axis.vertical, bool fit = true, Color? backgroundColor}) {
  int maxWidth = 0;
  int maxHeight = 0;
  //calculate max width/height of image
  for (var image in imageList) {
    if (direction == Axis.vertical) {
      if (maxWidth < image.width) maxWidth = image.width;
    } else {
      if (maxHeight < image.height) maxHeight = image.height;
    }
  }
  int totalHeight = maxHeight;
  int totalWidth = maxWidth;
  ui.PictureRecorder recorder = ui.PictureRecorder();
  final paint = Paint();
  Canvas canvas = Canvas(recorder);
  double dx = 0;
  double dy = 0;
  //set background color
  if (backgroundColor != null) {
    canvas.drawColor(backgroundColor, BlendMode.srcOver);
  }
  //draw images into canvas
  for (var image in imageList) {
    double scaleDx = dx;
    double scaleDy = dy;
    double imageHeight = image.height.toDouble();
    double imageWidth = image.width.toDouble();
    if (fit) {
      //scale the image to same width/height
      canvas.save();
      if (direction == Axis.vertical && image.width != maxWidth) {
        canvas.scale(maxWidth / image.width);
        scaleDy *= imageWidth / maxWidth;
        imageHeight *= maxWidth / imageWidth;
      } else if (direction == Axis.horizontal && image.height != maxHeight) {
        canvas.scale(maxHeight / image.height);
        scaleDx *= imageHeight / maxHeight;
        imageWidth *= maxHeight / imageHeight;
      }

      canvas.drawImage(image, Offset(scaleDx, scaleDy), paint);
      canvas.restore();
    } else {
      //draw directly

      canvas.drawImage(image, Offset(dx, dy), paint);
    }
    //accumulate dx/dy
    if (direction == Axis.vertical) {
      dy += imageHeight;
      totalHeight += imageHeight.floor();
    } else {
      dx += imageWidth;
      totalWidth += imageWidth.floor();
    }
  }
  var pic = recorder.endRecording();
  //print(pic.toImageSync(totalWidth, totalHeight));
  return pic.toImageSync(totalWidth, totalHeight);
}
