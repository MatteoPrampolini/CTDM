import 'dart:io';

import 'package:path/path.dart' as path;

String getOriginalDiscPath(String packPath) {
  Directory originalDiscDir = Directory(
      path.join(path.dirname(path.dirname(packPath)), 'ORIGINAL_DISC'));
  if (!originalDiscDir.existsSync()) {
    throw Exception("ORIGINAL_DISC not found");
  }
  if (Directory(path.join(originalDiscDir.path, 'DATA')).existsSync()) {
    return path.join(originalDiscDir.path, 'DATA');
  }
  return path.join(originalDiscDir.path);
}
