import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ctdm/utils/exceptions_utils.dart';
import 'package:ctdm/utils/log_utils.dart';
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
  bool canBeToggled;
  Gecko(this.name, this.pal, this.usa, this.kor, this.jap, this.author,
      this.desc, this.baseName, this.mandatory,
      {this.canBeToggled = false});

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Gecko &&
        name == other.name &&
        author == other.author &&
        pal == other.pal &&
        usa == other.usa &&
        jap == other.jap &&
        kor == other.kor &&
        desc == other.desc &&
        baseName == other.baseName &&
        mandatory == other.mandatory;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        author.hashCode ^
        pal.hashCode ^
        usa.hashCode ^
        jap.hashCode ^
        kor.hashCode ^
        desc.hashCode ^
        baseName.hashCode ^
        mandatory.hashCode;
  }
}

// ignore: constant_identifier_names
enum GameVersion { PAL, USA, JAP, KOR }

Map<GameVersion, String> fileMap = Map.fromIterables(GameVersion.values,
    ['RMCP01.gct', 'RMCE01.gct', 'RMCJ01.gct', 'RMCK01.gct']);

String getLetterFromGameVersion(GameVersion gameVersion) {
  return fileMap[gameVersion]!.substring(3, 4);
}

void createEmptyGtcFiles(String codesPath) {
  for (String filePath in fileMap.values) {
    if (!File(path.join(codesPath, filePath)).existsSync()) {
      File(path.join(codesPath, filePath)).createSync();
    }
  }
}

void copyGeckoAssetsToPack(String packPath) {
  Directory codesFolder =
      Directory(path.join(path.dirname(path.dirname(packPath)), 'myCodes'));
  if (!codesFolder.existsSync()) {
    codesFolder.createSync();
  }
  String assetPath = path.join(path.dirname(Platform.resolvedExecutable),
      "data", "flutter_assets", "assets");
  File musicCheat1 = File(path
      .join(assetPath, 'gecko', 'Track Music Expander.json')
      .replaceAll(" ", "%20")); //flutter XD
  File musicCheat2 = File(path
      .join(assetPath, 'gecko', 'Automatic BRSAR Patching.json')
      .replaceAll(" ", "%20")); //flutter XD

  for (String elem in [
    "trackMusicExpander",
    "Track Music Expander",
    "automaticBrsarPatching",
    "Automatic BRSAR Patching"
  ]) {
    File f = File(path.join(
        path.dirname(path.dirname(packPath)), 'myCodes', '$elem.json'));
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  musicCheat1.copySync(path.join(path.dirname(path.dirname(packPath)),
      'myCodes', 'Track Music Expander.json'));

  musicCheat2.copySync(path.join(path.dirname(path.dirname(packPath)),
      'myCodes', 'Automatic BRSAR Patching.json'));
}

/// This function reads the JSON files from myCodes and generates 4 .gct files, one per region, within [packPath].
void updateGtcFiles(String packPath, File geckoTxt) {
  List<File> myGeckoFiles = [];
  if (!geckoTxt.existsSync()) {
    createGeckoTxt(packPath);
  }

  List<String> cheatsFiles = geckoTxt.readAsLinesSync();
  for (String filepath in cheatsFiles) {
    File tmp = File(path.join(path.dirname(path.dirname(packPath)), "myCodes",
        filepath.replaceAll(";toggle", "")));
    if (tmp.existsSync()) {
      myGeckoFiles.add(tmp);
    } else {
      logString(LogType.ERROR,
          "gecko.txt contains cheat: $filepath, but json file was not found in myCodes folder.");
      throw CtdmException(
          "gecko.txt contains cheat: $filepath, but json file was not found in myCodes folder.",
          null,
          "3003");
    }
  }
  List<Gecko> geckoFromTxt = parseGeckoTxt(packPath, geckoTxt);
  //write header
  for (GameVersion version in fileMap.keys) {
    File current = File(path.join(packPath, 'codes', fileMap[version]));
    Uint8List header =
        Uint8List.fromList([00, 208, 192, 222, 00, 208, 192, 222]);
    current.writeAsBytesSync(header);
  }
  //write cheats
  int i = 2;
  for (Gecko gecko in geckoFromTxt) {
    //for each gecko
    for (GameVersion version in fileMap.keys) {
      File current =
          File(path.join(packPath, 'codes', fileMap[version])); //get .gct file
      if (gecko.canBeToggled) {
        //toggle begin
        current.writeAsBytesSync(
            hexToUint8List(
                "280015${i.toRadixString(16).padLeft(2, '0')}00000001"),
            mode: FileMode.append);
      }
      try {
        current.writeAsBytesSync(geckoToHex(gecko, version),
            mode: FileMode.append);
      } catch (e, stacktrace) {
        if (e.runtimeType == FormatException) {
          throw CtdmException(
              "'myCodes/${gecko.baseName}' (${version.name}) is invalid.\n'${(e as FormatException).source}' is not a valid hexadecimal value.",
              stacktrace,
              '3001');
        } else {
          throw CtdmException(
              "'myCodes/${gecko.baseName}' (${version.name}) is invalid.\nSomething is missing?",
              stacktrace,
              '3002');
        }
      }
      if (gecko.canBeToggled) {
        //toggle end
        current.writeAsBytesSync(hexToUint8List("E000000080008000"),
            mode: FileMode.append);
      }
    }
    if (gecko.canBeToggled) {
      i = i + 2;
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
      json['KOR'],
      json['JAP'],
      json['author'],
      json['desc'],
      path.basename(jsonFile.path.replaceAll(";toggle", "")),
      false);
  // json['name'] == "Automatic BRSAR Patching" ||
  //     json['name'] == "Track Music Expander");
}

Uint8List geckoToHex(Gecko gecko, GameVersion version) {
  String codeString;
  switch (version) {
    case GameVersion.PAL:
      codeString = gecko.pal;
      break;
    case GameVersion.USA:
      codeString = gecko.usa;
      break;
    case GameVersion.JAP:
      codeString = gecko.jap;
      break;
    case GameVersion.KOR:
      codeString = gecko.kor;
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

int compareGecko(Gecko a, Gecko b) {
  final specialStrings = [
    "Automatic Brsar Patching.json",
    "Track Music Expander.json"
  ];
  final isASpecial = specialStrings.contains(a.baseName);
  final isBSpecial = specialStrings.contains(b.baseName);

  if (isASpecial && isBSpecial) {
    return specialStrings
        .indexOf(a.baseName)
        .compareTo(specialStrings.indexOf(b.baseName));
  } else if (isASpecial) {
    return -1;
  } else if (isBSpecial) {
    return 1;
  } else {
    return b.baseName.compareTo(a.baseName);
  }
}

File createGeckoTxt(String packPath) {
  File geckoTxt = File(path.join(packPath, "gecko.txt"));
  if (!geckoTxt.existsSync()) {
    geckoTxt.createSync();
    String contents =
        "Automatic BRSAR Patching.json\nTrack Music Expander.json\n";
    geckoTxt.writeAsStringSync(contents);
  }
  return geckoTxt;
}

writeGeckoTxt(List<Gecko> cheats, File geckoTxt) {
  if (!geckoTxt.existsSync()) createGeckoTxt(path.dirname(geckoTxt.path));

  String contents = "";

  for (Gecko cheat in cheats) {
    if (!cheat.canBeToggled) {
      contents += "${cheat.baseName}\n";
    } else {
      contents += "${cheat.baseName};toggle\n";
    }
  }
  geckoTxt.writeAsStringSync(contents, mode: FileMode.write);
}

List<Gecko> parseGeckoTxt(String packPath, File geckoTxt) {
  if (!geckoTxt.existsSync()) {
    createGeckoTxt(packPath);
    return [];
  }
  List<Gecko> list = [];

  List<String> cheatsFiles = geckoTxt.readAsLinesSync();
  for (String filepath in cheatsFiles) {
    File tmp = File(path.join(path.dirname(path.dirname(packPath)), "myCodes",
        filepath.replaceAll(";toggle", "")));
    if (tmp.existsSync()) {
      //print(tmp);
      list.add(fileToGeckoCode(tmp));
      if (filepath.contains(";toggle")) {
        list.last.canBeToggled = true;
      }
    }
  }

  return list;
}
