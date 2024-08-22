import 'dart:io';

import 'package:ctdm/gui_elements/types.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CupTableHeader extends StatefulWidget {
  final int cupIndex;
  final String packPath;
  final int iconIndex;

  const CupTableHeader(this.cupIndex, this.packPath, this.iconIndex,
      {super.key});

  @override
  State<CupTableHeader> createState() => _CupTableHeaderState();
}

class _CupTableHeaderState extends State<CupTableHeader> {
  late bool canDelete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.red, border: Border.all(color: Colors.black)),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Track Name",
                        style: TextStyle(color: Colors.black87),
                      ),
                      Visibility(
                        visible: widget.cupIndex > 0,
                        child: IconButton(
                            onPressed: () => {
                                  canDelete = !canDelete,
                                  DeleteModeUpdated(canDelete, widget.cupIndex)
                                      .dispatch(context),
                                  setState(() => {})
                                },
                            icon: Icon(
                              Icons.delete,
                              color: canDelete ? Colors.amber : Colors.black87,
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Center(
                child: Text("track slot",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     decoration:
          //         BoxDecoration(border: Border.all(color: Colors.black)),
          //     child: const Center(
          //       child: Text("music slot",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(color: Colors.black87)),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 3,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("File Path",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Music path",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: FutureBuilder<bool>(
                future:
                    _checkFileExists(), // Metodo asincrono che controlla l'esistenza del file
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Mostra un indicatore di caricamento mentre l'operazione è in corso
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Gestisci eventuali errori durante il caricamento
                    return const Text("Error loading image");
                  } else if (snapshot.hasData && snapshot.data == true) {
                    // Se il file esiste, carica e mostra l'immagine
                    return Image.file(
                      File(path.join(
                          widget.packPath, 'Icons', '${widget.iconIndex}.png')),
                    );
                  } else {
                    // Se il file non esiste, mostra un testo o un'icona di fallback
                    return widget.iconIndex > 0
                        ? Text("${widget.iconIndex}.png")
                        : const Text("");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkFileExists() async {
    final filePath =
        path.join(widget.packPath, 'Icons', '${widget.iconIndex}.png');
    return File(filePath).exists();
  }
}
