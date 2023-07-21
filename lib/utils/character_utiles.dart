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
  'Funky Kong':
      'funky', //per qualche strano motivo, la versione 32x32 si chiama fuky
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
patchSzsWithImages(String packPath, Directory extractedSzs,
    List<String> charactersTxtLines, int index) async {
  //List<String> replacementsPaths = [];
  List<Directory> dir64List = getDirsFromFileIndex(
      packPath, SceneComplete.values[index], extractedSzs)[0];
  List<Directory> dir32List = getDirsFromFileIndex(
      packPath, SceneComplete.values[index], extractedSzs)[1];
  if (dir64List.isEmpty) return;

  int i = 0;
  for (String line in charactersTxtLines) {
    String relFolder = line.split(';')[1];
    if (relFolder.isEmpty) {
      i++;
      continue;
    }

    Directory absPathToCharFolder =
        Directory(path.join(packPath, 'myCharacters', relFolder));

    File icon64 =
        File(path.join(absPathToCharFolder.path, 'icons', 'icon64.png'));
    File icon32 =
        File(path.join(absPathToCharFolder.path, 'icons', 'icon32.png'));

    for (Directory dir64 in dir64List) {
      String filenameTpl = getOriginalFileNameForCharacter(i, false);
      await icon64.copy(path.join(dir64.path, "$filenameTpl.png"));
      await Process.run('wimgt ', [
        'encode',
        "$filenameTpl.png",
        '-o',
        path.join(dir64.path, filenameTpl)
      ]);
    }
    for (Directory dir32 in dir32List) {
      String filenameTpl = getOriginalFileNameForCharacter(i, true);
      await icon32.copy(path.join(dir32.path, "$filenameTpl.png"));
      await Process.run('wimgt ', [
        'encode',
        "$filenameTpl.png",
        '-o',
        path.join(dir32.path, filenameTpl)
      ]);
    }
    i++;
  }

  //TODO wszst CREATE per chiudere tutto
}

getDirsFromFileIndex(
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
    return "st_fuky_32x32.tpl.png";
  }
  String prefix = is32 ? "st_" : "tt";
  String name = characters2D.values.elementAt(charIndex);
  String suffix = is32 ? "_32x32.tpl" : "_64x64.tpl";
  return "$prefix$name$suffix";
}

//TODO COPIARE 2 FILE (menusingle già estratto), estrarli, chiamare patchSzsWithImages, 
//aggiungere al completeXml i 2 file