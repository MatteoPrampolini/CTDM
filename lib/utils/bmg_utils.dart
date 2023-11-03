final Map<String, String> vsMap = {
  "beginner_course": "Luigi Circuit",
  "farm_course": "Moo Moo Meadows",
  "kinoko_course": "Mushroom Gorge",
  "factory_course": "Toads Factory",
  "castle_course": "Mario Circuit",
  "shopping_course": "Coconut Mall",
  "boardcross_course": "DK's Snowboard Cross",
  "truck_course": "Wario's Gold Mine",
  "senior_course": "Daisy Circuit",
  "water_course": "Koopa Cape",
  "treehouse_course": "Maple Treeway",
  "volcano_course": "Grumble Volcano",
  "desert_course": "Dry Dry Ruins",
  "ridgehighway_course": "Moonview Highway",
  "koopa_course": "Bowser's Castle",
  "rainbow_course": "Rainbow Road",
  "old_peach_gc": "GCN Peach Beach",
  "old_falls_ds": "DS Yoshi Falls",
  "old_obake_sfc": "SNES Ghost Valley",
  "old_mario_64": "N64 Mario Raceway",
  "old_sherbet_64": "N64 Sherbet Land",
  "old_heyho_gba": "GBA Shy Guy Beach",
  "old_town_ds": "DS Delfino Square",
  "old_waluigi_gc": "GCN Waluigi Stadium",
  "old_desert_ds": "DS Desert Hills",
  "old_koopa_gba": "GBA Bowser Castle",
  "old_donkey_64": "N64 DK's Jungle Parkway",
  "old_mario_gc": "GCN Mario Circuit",
  "old_mario_sfc": "SNES Mario Circuit 3",
  "old_garden_ds": "DS Peach Gardens",
  "old_donkey_gc": "GCN DK Mountain",
  "old_koopa_64": "N64 Bowser Castle",
};
Map<String, String> battleMap = {
  "block_battle": "Block Plaza",
  "venice_battle": "Delfino Pier",
  "skate_battle": "Funky Stadium",
  "casino_battle": "Chain Chomp Wheel",
  "sand_battle": "Thwomp Desert",
  "old_battle4_sfc": "SNES Battle Course 4",
  "old_battle3_gba": "GBA Battle Course 3",
  "old_matenro_64": "N64 Skyscraper",
  "old_CookieLand_gc": "GCN Cookie Land",
  "old_House_ds": "DS Twilight House",
};

String getIdFromArenaCupTrack(int cup, int index) {
  //see: https://wiki.tockdom.com/wiki/Slot
  int uniqueIndex = cup * 5 + index;
  String returnValue = "";
  switch (uniqueIndex) {
    case 0:
      returnValue = "021";
      break;
    case 1:
      returnValue = "020";
      break;
    case 2:
      returnValue = "023";
      break;
    case 3:
      returnValue = "022";
      break;
    case 4:
      returnValue = "024";
      break;
    case 5:
      returnValue = "027";
      break;
    case 6:
      returnValue = "028";
      break;
    case 7:
      returnValue = "029";
      break;
    case 8:
      returnValue = "25";
      break;
    case 9:
      returnValue = "26";
      break;
  }
  return returnValue;
}
