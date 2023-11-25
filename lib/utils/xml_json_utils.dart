import 'dart:io';
import 'package:ctdm/utils/character_utiles.dart';
import 'package:path/path.dart' as path;
import 'package:ctdm/utils/gecko_utils.dart';
import 'dart:convert';

//XML
void completeXmlFile(
    String packid,
    String packPath,
    bool isOnline,
    String regionId,
    List<bool> customUI,
    List<File> sceneFiles,
    List<String> allKartsList,
    List<Gecko> geckoList) {
  String packName = path.basename(packPath);
  File xmlFile = File(path.join(packPath, "$packName.xml"));
  String contents = xmlFile.readAsStringSync();

  String onlinePart =
      isOnline ? '<memory offset="0x800017C4" value="$regionId"/>' : '';

  String customChar = xmlReplaceCharactersModelScenes(packPath, allKartsList);

  //String  = "";

  contents = clearOptions(contents);

  contents = clearPatchesXml(contents);

  int i = 2;
  for (Gecko gecko in geckoList) {
    if (gecko.canBeToggled) {
      contents =
          appendOption(createOptionString(gecko.name, gecko.name), contents);
      contents = appendPatch(
          createPatchString(gecko.name, i.toRadixString(16).padLeft(2, '0')),
          contents);

      i += 2;
    }
  }
  contents = appendOption(createMyStuffOptionString(), contents);
  contents = appendPatch(createMyStuffPatchString(packName), contents);
  contents = contents.replaceFirst(
      RegExp(r'<!--CUSTOM CHARACTERS-->.*<!--FINAL END-->', dotAll: true),
      "$customChar\n\t\t$onlinePart\n\t\t<!--FINAL END-->\t\t");

  //XmlDocument document = XmlDocument.parse(contents);
  //xmlFile.writeAsStringSync(document.toXmlString(pretty: true, indent: '\t'));

  xmlFile.writeAsStringSync(contents);
}

String clearOptions(String xmlContents) {
  int sectionStartIndex = xmlContents.indexOf('<section');
  int sectionEndIndex =
      xmlContents.indexOf('</section>', sectionStartIndex - 1);

  if (sectionStartIndex != -1 && sectionEndIndex != -1) {
    String sectionContent =
        xmlContents.substring(sectionStartIndex, sectionEndIndex + 10);

    // Trova l'indice della fine della prima opzione
    int firstOptionEndIndex = sectionContent.indexOf('</option>', 1);

    // Verifica se ci sono altre opzioni oltre la prima
    if (firstOptionEndIndex != -1) {
      // Rimuovi tutte le opzioni tranne la prima dalla sezione
      sectionContent =
          '${sectionContent.substring(0, firstOptionEndIndex + 9)}</section>';
    }

    xmlContents = xmlContents.replaceRange(
        sectionStartIndex, sectionEndIndex + 10, sectionContent);
  }

  return xmlContents;
}

String appendOption(String option, String xmlContents) {
  int sectionIndex = xmlContents.indexOf('</section>');

  if (sectionIndex != -1) {
    return xmlContents.replaceRange(sectionIndex, sectionIndex, option);
  } else {
    return xmlContents;
  }
}

String createOptionString(String name, String id) {
  return '''
    <option name="$name">
      <choice name="Enable"><patch id="$id"/></choice>
    </option>
  ''';
}

String createMyStuffOptionString() {
  return '''
    <option name="My Stuff">
      <choice name="Enable"><patch id="myStuff"/></choice>
    </option>
  ''';
}

String createPatchString(String id, String offset) {
  return '''
    <patch id="$id">
      <memory offset="0x800015$offset" value="0001"/>
    </patch>
  ''';
}

String createMyStuffPatchString(String packname) {
  return '''
    <patch id="myStuff">
      <folder external="/$packname/myStuff" recursive="false" />
		  <folder external="/$packname/myStuff" disc="/" />
    </patch>
  ''';
}

String appendPatch(String patch, String fileContents) {
  // Cerca l'indice della chiusura di "</wiidisc>"
  int wiidiscClosingIndex = fileContents.lastIndexOf("</wiidisc>");

  // Se non trova la chiusura di "</wiidisc>", restituisci la stringa originale
  if (wiidiscClosingIndex == -1) {
    return fileContents;
  }

  // Crea la nuova stringa con la patch aggiunta prima della chiusura di "</wiidisc>"
  String patchedFileContents = fileContents.substring(0, wiidiscClosingIndex) +
      patch +
      fileContents.substring(wiidiscClosingIndex);

  return patchedFileContents;
}

String clearPatchesXml(String fileContents) {
  // Cerca l'indice della prima occorrenza di "<patch>"
  int startIndex = fileContents.indexOf("<patch");

  // Se non trova "<patch>", restituisci la stringa originale
  if (startIndex == -1) {
    return fileContents;
  }

  // Cerca l'indice della chiusura di "</patch>" successiva alla prima occorrenza
  int endIndex = fileContents.indexOf("</patch>", startIndex);

  // Se non trova la chiusura di "</patch>", restituisci la stringa originale
  if (endIndex == -1) {
    return fileContents;
  }

  // Trova l'indice della chiusura di "</wiidisc>"
  int wiidiscClosingIndex = fileContents.lastIndexOf("</wiidisc>");

  // Se non trova la chiusura di "</wiidisc>", restituisci la stringa originale
  if (wiidiscClosingIndex == -1) {
    return fileContents;
  }

  // Estrai la parte del testo prima della prima patch
  String result = fileContents.substring(0, startIndex);

  // Aggiungi la prima patch al risultato
  result += fileContents.substring(startIndex, endIndex + "</patch>".length);

  // Aggiungi la parte di testo dopo la chiusura di "</wiidisc>"
  result += "${fileContents.substring(wiidiscClosingIndex)}\n";

  return result;
}

//JSON
Map<String, dynamic> renameFirstOptionName(
    String packId, Map<String, dynamic> jsonData) {
  if (jsonData.containsKey("riivolution") &&
      jsonData["riivolution"].containsKey("patches") &&
      jsonData["riivolution"]["patches"].isNotEmpty) {
    var patches = jsonData["riivolution"]["patches"];
    if (patches[0].containsKey("options") && patches[0]["options"].isNotEmpty) {
      var options = patches[0]["options"];
      if (options[0].containsKey("option-name")) {
        options[0]["option-name"] = packId;
      }
    }
  }

  return jsonData;
}

String addPatchJson(String name, String packid, String contents) {
  Map<String, dynamic> jsonContent = json.decode(contents);

  List<dynamic> patches = jsonContent['riivolution']['patches'];

  int patchIndex = -1;
  for (int i = 0; i < patches.length; i++) {
    if (patches[i].containsKey('options')) {
      patchIndex = i;
      break;
    }
  }

  List<dynamic> options =
      patchIndex != -1 ? patches[patchIndex]['options'] : [];

  options.add({
    "choice": 1,
    "option-name": name,
    "section-name": packid,
  });

  if (patchIndex != -1) {
    patches[patchIndex]['options'] = options;
  } else {
    Map<String, dynamic> newPatch = {
      "options": options,
      "root": "C:\\Users\\matte\\Documents\\CT_test\\CTDM_workspace/Packs/",
      "xml":
          "C:\\Users\\matte\\Documents\\CT_test\\CTDM_workspace\\Packs\\multipatch/multipatch.xml",
    };
    patches.add(newPatch);
  }

  jsonContent['riivolution']['patches'] = patches;

  return json.encode(jsonContent);
}

String clearPatchesJson(String contents) {
  Map<String, dynamic> jsonContent = json.decode(contents);

  List<dynamic> patches = jsonContent['riivolution']['patches'];

  for (var patch in patches) {
    if (patch.containsKey('options') && patch['options'].length > 1) {
      patch['options'] = [patch['options'].first];
    }
  }

  jsonContent['riivolution']['patches'] = patches;

  return json.encode(jsonContent);
}

void replaceJsonValues(
    Map<dynamic, dynamic> jsonMap, Map<String, dynamic> replacements) {
  jsonMap.forEach((key, value) {
    if (replacements.containsKey(key)) {
      jsonMap[key] = replacements[key];
    }
    if (value is Map) {
      replaceJsonValues(value, replacements);
    } else if (value is List) {
      for (var element in value) {
        if (element is Map) {
          replaceJsonValues(element, replacements);
        }
      }
    }
  });
}

void replaceParamsInJson(
  File jsonFile,
  String chosenName,
  String chosenId,
  String game,
  String dolphin,
) {
  String packPath = path.dirname(jsonFile.path);
  String workspace = path.dirname(path.dirname(packPath));

  String contents = jsonFile.readAsStringSync();

  Map<String, dynamic> jsonData = json.decode(contents);
  renameFirstOptionName(chosenId, jsonData);
  Map<String, dynamic> replacements = {
    "base-file": game,
    "display-name": chosenName,
    "section-name": chosenId,
    "root": "$workspace/Packs/",
    "xml": "$packPath/$chosenName.xml",
  };

  replaceJsonValues(jsonData, replacements);

  String modifiedJsonString = json.encode(jsonData);
  String prettifiedJsonString = const JsonEncoder.withIndent('  ')
      .convert(json.decode(modifiedJsonString));

  jsonFile.writeAsStringSync(prettifiedJsonString);
}

void createXmlFile(String xmlPath) {
  String assetPath = path.join(path.dirname(Platform.resolvedExecutable),
      "data", "flutter_assets", "assets");

  File(path.join(assetPath, 'Pack.xml')).copySync(xmlPath);
  // Directory assetFolder = Directory(assetPath);
  // List<File> xmlFileList = assetFolder.listSync().whereType<File>().toList();
  // xmlFileList.retainWhere((element) => element.path.endsWith('xml'));

  // xmlFileList.first.copySync(xmlPath);
  //final File xmlFile = File("assets/Pack.xml");
  //xmlFile.copySync(xmlPath);
}

(String, String) getPackNameAndId(String packPath) {
  File xmlFile = File(path.join(packPath, '${path.basename(packPath)}.xml'));
  String contents = xmlFile.readAsStringSync();

  String packId = contents.split(RegExp(r'patch id='))[1];
  packId =
      packId.replaceRange(packId.indexOf(r'/'), null, '').replaceAll('"', '');
  return (path.basename(packPath), packId);
}

void replaceParamsInXml(
    File xmlFile, String chosenName, String chosenId, String version) {
  String contents = xmlFile.readAsStringSync();
  // final versionRegex = RegExp(r'-[A-Z]+.bin');
  contents = contents.replaceFirst('CTDM_VERSION', version);
  // contents = contents.replaceAll(versionRegex, '-$isoVersion.bin');
  // String oldName = contents.split(RegExp(r'<section name='))[1];
  // oldName =
  //     oldName.replaceRange(oldName.indexOf('>'), null, '').replaceAll('"', '');
  // String oldId = contents.split(RegExp(r'patch id='))[1];

  // oldId = oldId.replaceRange(oldId.indexOf(r'/'), null, '').replaceAll('"', '');
  String oldName, oldId;
  (oldName, oldId) = getPackNameAndId(path.dirname(xmlFile.path));
  //contents = contents.replaceAll(versionRegex, '-$isoVersion.bin');

  contents = contents.replaceAll(oldName, chosenName);

  contents = contents.replaceAll(oldId, chosenId);

  xmlFile.writeAsStringSync(contents, mode: FileMode.write);
}

//XML AND JSON
void saveAndRenamePack(String packPath, String chosenName, String chosenId,
    String version, String game, String dolphin) {
  Directory dir = Directory(packPath);
  List<FileSystemEntity> entities = dir.listSync().toList();
  Iterable<File> xmlList = entities
      .whereType<File>()
      .where((element) => element.path.endsWith('.xml'));

  if (xmlList.isEmpty) {
    createXmlFile(
        path.join(packPath, '${path.basenameWithoutExtension(packPath)}.xml'));
  }

  dir = Directory(packPath);
  entities = dir.listSync().toList();
  xmlList = entities
      .whereType<File>()
      .where((element) => element.path.endsWith('.xml'));
  File xmlFile = xmlList.first;

  replaceParamsInXml(xmlFile, chosenName, chosenId, version);

  xmlFile.renameSync(path.join(packPath, "$chosenName.xml"));

  dir.renameSync(path.join(path.dirname(packPath), chosenName));
  Iterable<File> jsonList = entities
      .whereType<File>()
      .where((element) => element.path.endsWith('.json'));

  if (jsonList.isEmpty) {
    String jsonOgPath = path.join(path.dirname(Platform.resolvedExecutable),
        "data", "flutter_assets", "assets", "Pack.json");
    File(jsonOgPath)
        .copySync(path.join(path.dirname(packPath), chosenName, 'Pack.json'));
    //createXmlFile(path.join(packPath, 'Pack.json'));
  }
  dir = Directory(path.join(path.dirname(packPath), chosenName));
  entities = dir.listSync().toList();
  jsonList = entities
      .whereType<File>()
      .where((element) => element.path.endsWith('.json'));
  File jsonFile = jsonList.first;
  replaceParamsInJson(jsonFile, chosenName, chosenId, game, dolphin);
  //3
  jsonFile.renameSync(
      path.join(path.dirname(packPath), chosenName, "$chosenName.json"));
}
