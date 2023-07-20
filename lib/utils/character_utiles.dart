import 'dart:io';
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

createCharacterFolders(Directory dir) async {
  if (await dir.exists() == false) {
    await dir.create();
  }
  characters2D.forEach((key, value) async {
    if (await Directory(path.join(dir.path, key)).exists() == false) {
      await Directory(path.join(dir.path, key)).create();
      await Directory(path.join(dir.path, key, 'icons')).create();
      await Directory(path.join(dir.path, key, 'karts')).create();
      await Directory(path.join(dir.path, key, 'voices')).create();
    }
  });
}
