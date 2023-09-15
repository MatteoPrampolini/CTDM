import 'package:ctdm/drawer_options/brstm_player.dart/player.dart';
import 'package:flutter/material.dart';

class DoubleBrstmPlayer extends StatefulWidget {
  const DoubleBrstmPlayer({super.key});

  @override
  State<DoubleBrstmPlayer> createState() => _DoubleBrstmPlayerState();
}

class _DoubleBrstmPlayerState extends State<DoubleBrstmPlayer> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [BrstmPlayer(), Divider(), BrstmPlayer()],
    );
  }
}
