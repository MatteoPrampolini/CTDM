import 'dart:io';
import 'package:ctdm/drawer_options/custom_ui.dart';
import 'package:path/path.dart' as path;

final Map<String, String> characters2D = {
  'Baby Mario': 'baby_mario',
  'Baby Luigi': 'baby_luigi',
  'Baby Peach': 'baby_peach',
  'Baby Daisy': 'baby_daisy',
  'Toad': 'kinopio',
  'Toadette': 'kinopico',
  'Koopa Troopa': 'noko',
  'Dry Bones': 'karon',
  'Mario': 'mario',
  'Luigi': 'luigi',
  'Peach': 'peach',
  'Daisy': 'daisy',
  'Yoshi': 'yoshi',
  'Birdo': 'catherine',
  'Diddy Kong': 'didy',
  'Bowser Jr': 'koopa_jr',
  'Wario': 'wario',
  'Waluigi': 'waluigi',
  'Donkey Kong': 'donky',
  'Bowser': 'koopa',
  'King Boo': 'teresa',
  'Rosalina': 'roseta',
  'Funky Kong': 'funky',
  'Dry Bowser': 'hone_koopa',
};

final Map<String, String> characters3D = {
  'Baby Mario': 'bmr',
  'Baby Luigi': 'blg',
  'Baby Peach': 'bpc',
  'Baby Daisy': 'bds',
  'Toad': 'ko',
  'Toadette': 'kk',
  'Koopa Troopa': 'nk',
  'Dry Bones': 'ka',
  'Mario': 'mr',
  'Luigi': 'lg',
  'Peach': 'pc',
  'Daisy': 'ds',
  'Yoshi': 'ys',
  'Birdo': 'ca',
  'Diddy Kong': 'dd',
  'Bowser Jr': 'jr',
  'Wario': 'wr',
  'Waluigi': 'wl',
  'Donkey Kong': 'dk',
  'Bowser': 'kp',
  'King Boo': 'kt',
  'Rosalina': 'rs',
  'Funky Kong': 'fk',
  'Dry Bowser': 'bk',
};
int nVehiclesPerSize = 16;
final Map<String, String> vehicles = {
  //large
  "Flame Runner": "la_bike",
  "Offroader": "la_kart",
  "Wario Bike": "lb_bike",
  "Flame Flyer": "lb_kart",
  "Shooting Star": "lc_bike",
  "Piranha Prowler": "lc_kart",
  "Spear": "ld_bike",
  "Jetsetter": "ld_kart",
  "Standard Bike L": "ldf_bike",
  "Standard Kart L": "ldf_kart",
  "Standard Bike L (Battle Mode + Blue Team)": "ldf_bike_blue",
  "Standard Bike L (Battle Mode + Red Team)": "ldf_bike_red",
  "Standard Kart L (Battle Mode + Blue Team)": "ldf_kart_blue",
  "Standard Kart L (Battle Mode + Red Team)": "ldf_kart_red",
  "Phantom": "le_bike",
  "Honeycoupe": "le_kart",
  //medium
  "Mach Bike": "ma_bike",
  "Classic Dragster": "ma_kart",
  "Sugarscoot": "mb_bike",
  "Wild Wing": "mb_kart",
  "Zip Zip": "mc_bike",
  "Super Blooper": "mc_kart",
  "Sneakster": "md_bike",
  "Daytripper": "md_kart",
  "Standard Bike M": "mdf_bike",
  "Standard Kart M": "mdf_kart",
  "Standard Bike M (Battle Mode + Blue Team)": "mdf_bike_blue",
  "Standard Bike M (Battle Mode + Red Team)": "mdf_bike_red",
  "Standard Kart M (Battle Mode + Blue Team)": "mdf_kart_blue",
  "Standard Kart M (Battle Mode + Red Team)": "mdf_kart_red",
  "Dolphin Dasher": "me_bike",
  "Sprinter": "me_kart",
  //small
  "Bullet Bike": "sa_bike",
  "Booster Seat": "sa_kart",
  "Bit Bike": "sb_bike",
  "Mini Beast": "sb_kart",
  "Quacker": "sc_bike",
  "Cheep Charger": "sc_kart",
  "Magikruiser": "sd_bike",
  "Tiny Titan": "sd_kart",
  "Standard Bike S": "sdf_bike",
  "Standard Kart S": "sdf_kart",
  "Standard Bike S (Battle Mode + Blue Team)": "sdf_bike_blue",
  "Standard Bike S (Battle Mode + Red Team)": "sdf_bike_red",
  "Standard Kart S (Battle Mode + Blue Team)": "sdf_kart_blue",
  "Standard Kart S (Battle Mode + Red Team)": "sdf_kart_red",
  "Jet Bubble": "se_bike",
  "Blue Falcon": "se_kart"
};
// createCharacterFolders(Directory dir) async {
//   if (await dir.exists() == false) {
//     await dir.create();
//   }
//   characters2D.forEach((key, value) async {
//     if (await Directory(path.join(dir.path, key)).exists() == false) {
//       await Directory(path.join(dir.path, key)).create();
//       await Directory(path.join(dir.path, key, 'icons')).create();
//       await Directory(path.join(dir.path, key, 'karts')).create();
//       await Directory(path.join(dir.path, key, 'voices')).create();
//     }
//   });
// }
patchWithBrres(Directory extractedSzs, File brress, String subFolderpath) {}
patchSzsWithImages(String packPath, Directory extractedSzs,
    List<String> charactersTxtLines, int index) async {
  //List<String> replacementsPaths = [];
  List<Directory> dir64List = List<Directory>.from(getDirsFromFileIndex(
      packPath, SceneComplete.values[index], extractedSzs)[0]);
  List<Directory> dir32List = List<Directory>.from(getDirsFromFileIndex(
      packPath, SceneComplete.values[index], extractedSzs)[1]);
  if (dir64List.isEmpty) return;

  int i = 0;
  for (String line in charactersTxtLines) {
    String relFolder = line.split(';')[1];
    if (relFolder.isEmpty) {
      i++;
      continue;
    }

    Directory absPathToCharFolder = Directory(path.join(
        path.dirname(path.dirname(packPath)), 'myCharacters', relFolder));

    File icon64 =
        File(path.join(absPathToCharFolder.path, 'icons', 'icon64.png'));
    File icon32 =
        File(path.join(absPathToCharFolder.path, 'icons', 'icon32.png'));

    for (Directory dir64 in dir64List) {
      String filenameTpl = getOriginalFileNameForCharacter(i, false);

      await icon64.copy(path.join(dir64.path, "$filenameTpl.png"));
      await Process.run(
          'wimgt',
          [
            'encode',
            path.join(dir64.path, "$filenameTpl.png"),
            '--dest',
            path.join(dir64.path, filenameTpl),
            '-o'
          ],
          runInShell: true);
    }
    for (Directory dir32 in dir32List) {
      String filenameTpl = getOriginalFileNameForCharacter(i, true);
      //print(path.join(dir32.path, "$filenameTpl.png"));
      await icon32.copy(path.join(dir32.path, "$filenameTpl.png"));
      await Process.run(
          'wimgt',
          [
            'encode',
            path.join(dir32.path, "$filenameTpl.png"),
            '--dest',
            path.join(dir32.path, filenameTpl),
            '-o',
          ],
          runInShell: true);
    }
    i++;
  }
  String fileBaseName = path.basename(getFileFromIndex(packPath, index).path);
  await Process.run(
      'wszst',
      [
        'CREATE',
        extractedSzs.path,
        '-o',
        '--dest',
        path.join(path.dirname(extractedSzs.path), fileBaseName)
      ],
      runInShell: true);
  return;
}

List getDirsFromFileIndex(
    String packPath, SceneComplete index, Directory extractedDir) {
  switch (index) {
    case SceneComplete.award:
      return [
        [Directory(path.join(extractedDir.path, 'award', 'timg'))],
        []
      ];
    case SceneComplete.award_:
      return [[], []];
    case SceneComplete.channel:
      return [[], []];
    case SceneComplete.channel_:
      return [[], []];
    case SceneComplete.event:
      return [[], []];
    case SceneComplete.event_:
      return [[], []];
    case SceneComplete.globe:
      return [[], []];
    case SceneComplete.globe_:
      return [[], []];
    case SceneComplete.menuMulti:
      return [[], []];
    case SceneComplete.menuMulti_:
      return [[], []];
    case SceneComplete.menuOther:
      return [[], []];
    case SceneComplete.menuOther_:
      return [[], []];
    case SceneComplete.menuSingle:
      return [
        [Directory(path.join(extractedDir.path, 'button', 'timg'))],
        []
      ];
    case SceneComplete.menuSingle_:
      return [[], []];

    case SceneComplete.present:
      return [[], []];
    case SceneComplete.present_:
      return [[], []];
    case SceneComplete.race:
      return [
        [
          Directory(path.join(extractedDir.path, 'game_image', 'timg')),
          Directory(path.join(extractedDir.path, 'result', 'timg'))
        ],
        [Directory(path.join(extractedDir.path, 'game_image', 'timg'))]
      ];
    case SceneComplete.race_:
      return [[], []];

    case SceneComplete.title:
      return [[], []];
    case SceneComplete.title_:
      return [[], []];
  }
}

getOriginalFileNameForCharacter(int charIndex, bool is32) {
  if (charIndex == 22 && is32 == true) {
    return "st_fuky_32x32.tpl";
  }
  String prefix = is32 ? "st_" : "tt_";
  String name = characters2D.values.elementAt(charIndex);
  String suffix = is32 ? "_32x32.tpl" : "_64x64.tpl";
  return "$prefix$name$suffix";
}

int getNumberOfCustomCharacters(File charTxt) {
  if (!charTxt.existsSync()) return 0;
  return charTxt
      .readAsLinesSync()
      .where((element) => element.split(';')[1].isNotEmpty)
      .length;
}

///
String xmlReplaceCharactersModelScenes(
    String packPath, List<String> allKartsList) {
  String bigString = '\n\t\t<!--CUSTOM CHARACTERS-->\n';
  for (File f in Directory(path.join(packPath, 'Race', 'Kart'))
      .listSync()
      .whereType<File>()
      .toList()) {
    String basename = path.basename(f.path);
    //create is not needed here, but it can avoid errors if the user places wrong files inside the custChar/kart/ folder
    bigString +=
        '\t\t<file disc="/Race/Kart/$basename" external="/${path.basename(packPath)}/Race/Kart/$basename" create="true"/>\n';
  }
  for (String allKartPath in allKartsList) {
    bigString +=
        '\t\t<file disc="/Scene/Model/Kart/$allKartPath" external="/${path.basename(packPath)}/Scene/Model/Kart/$allKartPath"/>\n';
  }
  bigString += "\t\t<!--END CUSTOM CHARACTERS-->\n\t\t";
  return bigString;
}

String getPathOfCustomCharacter(String packPath, String dirBasename) {
  return path.join(
      path.dirname(path.dirname(packPath)), 'myCharacters', dirBasename);
}

List<Directory> getListOfCharactersDir(String packPath) {
  return Directory(
          path.join(path.dirname(path.dirname(packPath)), 'myCharacters'))
      .listSync()
      .whereType<Directory>()
      .toList();
}

enum Size { large, medium, small }

class CustomCharacter {
  Directory dir;
  late String dirBasename;
  late String name;
  late File? icon64;
  late File? icon32;
  late Size size;
  late Map<String, String> subVehicles;
  late List<String> subVehiclesNames;
  List<String> fileListPath = [];
  late File configFile;
  CustomCharacter(this.dir) {
    configFile = File(path.join(dir.path, 'ctdm_settings.txt'));
    dirBasename = path.basename(dir.path);
    icon64 = File(path.join(dir.path, 'icons', 'icon64.png'));
    icon32 = File(path.join(dir.path, 'icons', 'icon32.png'));

    if (configFile.existsSync()) {
      size =
          Size.values[int.parse(configFile.readAsLinesSync()[0].split(';')[1])];
      name = configFile.readAsLinesSync()[1].split(';')[1];
    } else {
      configFile.writeAsStringSync("size;2\nname; ", mode: FileMode.writeOnly);
      size = Size.small;
      name = " ";
    }

    _createFilelist();
  }
  _createFilelist() {
    fileListPath = [];

    //fileListPath.add(RegExp(r'karts\/*.allkart\.szs'));
    subVehiclesNames = vehicles.keys
        .skip(nVehiclesPerSize * size.index)
        .take(nVehiclesPerSize)
        .toList();
    subVehicles = Map.fromEntries(vehicles.entries
        .skip(nVehiclesPerSize * size.index)
        .take(nVehiclesPerSize));
    for (String value in subVehicles.values) {
      fileListPath.add(path.join('Race', 'Kart', value).replaceAll('.szs', ''));
      //fileListPath.add(RegExp(r'karts\/.*' + RegExp.escape(value) + r'\.szs'));
    }
  }

  void rewriteFile(int selectedSizeIndex, String name) {
    size = Size.values[selectedSizeIndex];
    configFile.writeAsStringSync("size;$selectedSizeIndex\nname;$name",
        mode: FileMode.writeOnly);
    _createFilelist();
  }
}

List<CustomCharacter> createListOfCharacter(String packPath) {
  List<CustomCharacter> chars = [];
  getListOfCharactersDir(packPath).forEach((dir) {
    chars.add(CustomCharacter(dir));
  });
  return chars;
}

File findFilePath(Directory dir, String basename) {
  File f = dir.listSync(recursive: true).whereType<File>().firstWhere(
        (element) => element.path.contains(path.basename(basename)),
        orElse: () => File("$basename;${dir.path};not found #######"),
      );
  return f;
}

List<String> findKeysByValue(Map<String, String> map, String targetValue) {
  List<String> keys = [];
  map.forEach((key, value) {
    if (value == targetValue) {
      keys.add(key);
    }
  });
  return keys;
}

String findFirstKeyByValue(Map<String, String> map, String targetValue) {
  for (var entry in map.entries) {
    if (entry.value == targetValue) {
      return entry.key;
    }
  }
  return '';
}

final Map<String, String> bmgCharacterMap = {
  'Baby Mario': '232e',
  'Baby Luigi': '2334',
  'Baby Peach': '2329',
  'Baby Daisy': '232c',
  'Toad': '2330',
  'Toadette': '2335',
  'Koopa Troopa': '2336',
  'Dry Bones': '232d',
  'Mario': '2328',
  'Luigi': '232f',
  'Peach': '2338',
  'Daisy': '2337',
  'Yoshi': '2332',
  'Birdo': '2339',
  'Diddy Kong': '233a',
  'Bowser Jr': '233c',
  'Wario': '2333',
  'Waluigi': '232a',
  'Donkey Kong': '2331',
  'Bowser': '232b',
  'King Boo': '233b',
  'Rosalina': '233f',
  'Funky Kong': '233e',
  'Dry Bowser': '233d',
};

String replaceCharacterNameInCommonTxt(
    String packPath, String commonTxtContents, String customTxtContent) {
  List<String> characterUsed = customTxtContent
      .split('\n')
      .where((line) =>
          line.isNotEmpty && line.replaceRange(0, line.indexOf(';'), '') != ";")
      .toList();

  List<CustomCharacter> chars = characterUsed
      .map((dirName) => CustomCharacter(Directory(path.join(
          path.dirname(path.dirname(packPath)),
          'myCharacters',
          dirName.split(';')[1]))))
      .toList();

  int i = 0;
  for (CustomCharacter char in chars) {
    String vanillaCharname = characterUsed[i].split(';')[0];
    String? id = bmgCharacterMap[vanillaCharname];

    if (id == null) {
      return commonTxtContents;
    }

    commonTxtContents = modifyValueByKey(id, char.name, commonTxtContents);

    i += 1;
  }

  return commonTxtContents;
}

String modifyValueByKey(String key, String newValue, String commonTxtContent) {
  final RegExp regex = RegExp(r'^\s*' + key.trim() + r'\s*=\s*(.*?)(?:\n|\r|$)',
      multiLine: true);
  final match = regex.firstMatch(commonTxtContent);

  if (match != null) {
    // Update the content directly using replaceFirst method
    String modifiedContent =
        commonTxtContent.replaceFirst(regex, '${key.trim()} = $newValue\n');
    return modifiedContent;
  } else {
    // The key specified doesn't exist, you can handle this case here if necessary.
    return commonTxtContent;
  }
}
