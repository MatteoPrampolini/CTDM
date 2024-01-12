import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

Future<img.Image> newMergeImages(List<File> imageList) async {
  // Ensure the imageList is not empty
  if (imageList.isEmpty) {
    throw Exception('Image list is empty');
  }

  List<img.Image> images = [];
  for (File file in imageList) {
    try {
      List<int> bytes = await file.readAsBytes();

      img.Image? decodedImage = img.decodeImage(Uint8List.fromList(bytes));
      if (decodedImage != null) {
        images.add(decodedImage);
      }
    } catch (e) {
      print('Error decoding image: $e');
    }
  }

  // Filter out any null images
  // Ensure there is at least one valid image
  if (images.isEmpty) {
    throw Exception('No valid images found');
  }

  // Calculate the total height of the stacked image
  //int totalHeight = images.length * images.first.height;

  // Create a new image with the same width as the first image and the calculated height
  img.Image resultImage = img.Image(
      width: 128,
      height: 128 * images.length,
      numChannels: 4,
      backgroundColor: img.ColorRgba8.from(img.ColorUint8.rgba(0, 0, 0, 0)));

  //Copy each image into the result image vertically
  int offsetY = 0;
  for (img.Image image in images) {
    img.compositeImage(
      resultImage,
      image,
      dstY: offsetY,
    );
    offsetY += image.height;
  }

  return resultImage;
}
