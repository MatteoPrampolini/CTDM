import 'dart:io';

import 'package:ctdm/drawer_options/cup_icons.dart';
import 'package:ctdm/drawer_options/lpar_config.dart';
import 'package:ctdm/drawer_options/rename_pack.dart';
import 'package:ctdm/drawer_options/select_gecko.dart';
//import 'package:ctdm/drawer_options/track_config.dart';
import 'package:ctdm/drawer_options/track_config_gui.dart';
//import 'package:ctdm/drawer_options/track_config_gui.dart';
import 'package:flutter/material.dart';

//import 'drawer_options/gecko_codes.dart';
import 'main.dart';

class CustomDrawer extends StatefulWidget {
  final String packPath;
  final bool xmlExist;
  const CustomDrawer(this.packPath, this.xmlExist, {super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void _onBackPressed(BuildContext context) {
    if (widget.packPath.contains('tmp_pack_')) {
      Directory(widget.packPath).deleteSync(recursive: true);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 89,
          child: DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BackButton(
                    onPressed: () => {_onBackPressed(context)},
                    color: Colors.red.shade700),
              ],
            ),
          ),
        ),
        ListTile(
          title: const Text('Pack name'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RenamePack(widget.packPath)));
          },
        ),
        ListTile(
          enabled: widget.xmlExist,
          title: const Text('Track config'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrackConfigGui(widget.packPath)));
          },
        ),
        ListTile(
          enabled: widget.xmlExist,
          title: const Text('Lpar'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LparConfig(widget.packPath)));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          enabled: widget.xmlExist,
          title: const Text('Cup icons'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CupIconsWindow(widget.packPath)));
            // Update the state of the app.
            // ...
          },
        ),
        const Divider(),
        ListTile(
          enabled: widget.xmlExist,
          title: const Text('Gecko codes'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectGecko(widget.packPath)));
            //GeckoCodes(widget.packPath)));
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ));
  }
}
