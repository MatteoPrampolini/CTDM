import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

class Gecko {
  String name;
  String author;
  String pal;
  String usa;
  String jap;
  String kor;

  String desc;
  String baseName;
  bool mandatory;
  Gecko(this.name, this.pal, this.usa, this.kor, this.jap, this.author,
      this.desc, this.baseName, this.mandatory);
}

// ignore: constant_identifier_names
enum GameVersion { PAL, USA, JAP, KOR }

Map<GameVersion, String> fileMap = Map.fromIterables(GameVersion.values,
    ['RMCP01.gct', 'RMCE01.gct', 'RMCJ01.gct', 'RMCK01.gct']);

void createEmptyGtcFiles(String codesPath) {
  for (String filePath in fileMap.values) {
    if (!File(path.join(codesPath, filePath)).existsSync()) {
      File(path.join(codesPath, filePath)).createSync();
    }
  }
}

void updateGtcFiles(String packPath) {
  createEmptyGtcFiles(path.join(packPath, 'codes'));
  List<File> myGeckoFiles = Directory(path.join(packPath, 'myCodes'))
      .listSync()
      .whereType<File>()
      .toList();

  //write header
  for (GameVersion version in fileMap.keys) {
    File current = File(path.join(packPath, 'codes', fileMap[version]));
    Uint8List header =
        Uint8List.fromList([00, 208, 192, 222, 00, 208, 192, 222]);
    current.writeAsBytesSync(header);
  }
  //write cheats
  for (File myGeckoFile in myGeckoFiles) {
    Gecko gecko = fileToGeckoCode(myGeckoFile);
    for (GameVersion version in fileMap.keys) {
      File current = File(path.join(packPath, 'codes', fileMap[version]));
      current.writeAsBytesSync(GeckoToHex(gecko, version),
          mode: FileMode.append);
    }
  }
  //write eof
  for (GameVersion version in fileMap.keys) {
    File current = File(path.join(packPath, 'codes', fileMap[version]));
    Uint8List eof = Uint8List.fromList([240, 00, 00, 00, 00, 00, 00, 00]);
    current.writeAsBytesSync(eof, mode: FileMode.append);
  }
}

Gecko fileToGeckoCode(File jsonFile) {
  var json = jsonDecode(jsonFile.readAsStringSync());
  return Gecko(
      json['name'],
      json['PAL'],
      json['USA'],
      json['JAP'],
      json['KOR'],
      json['author'],
      json['desc'],
      path.basename(jsonFile.path),
      json['name'] == "Automatic BRSAR Patching" ||
          json['name'] == "Track Music Expander");
}

Uint8List GeckoToHex(Gecko Gecko, GameVersion version) {
  String codeString;
  switch (version) {
    case GameVersion.PAL:
      codeString = Gecko.pal;
      break;
    case GameVersion.USA:
      codeString = Gecko.usa;
      break;
    case GameVersion.JAP:
      codeString = Gecko.jap;
      break;
    case GameVersion.KOR:
      codeString = Gecko.kor;
      break;
  }
  return hexToUint8List(codeString);
}

//https://pub.dev/documentation/eosdart/latest/eosdart/hexToUint8List.html
Uint8List hexToUint8List(String hex) {
  if (hex.length % 2 != 0) {
    throw 'Odd number of hex digits';
  }
  var l = hex.length ~/ 2;
  var result = Uint8List(l);
  for (var i = 0; i < l; ++i) {
    var x = int.parse(hex.substring(i * 2, (2 * (i + 1))), radix: 16);
    if (x.isNaN) {
      throw 'Expected hex string';
    }
    result[i] = x;
  }
  return result;
}