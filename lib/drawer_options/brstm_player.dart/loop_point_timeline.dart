import 'package:brstm_player/brstm.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';

class LoopPointTimeline extends StatefulWidget {
  final int startLoop;
  final int totalSamples;
  final int endLoop;
  final int sampleRate;
  final double size;
  final ValueChanged<double> onLoopPointChange;

  const LoopPointTimeline({
    required this.startLoop,
    required this.totalSamples,
    required this.endLoop,
    required this.sampleRate,
    required this.onLoopPointChange,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  State<LoopPointTimeline> createState() => LoopPointTimelineState();
}

class LoopPointTimelineState extends State<LoopPointTimeline> {
  int _startLoop = 0;
  int _endLoop = 1;
  int _totalSamples = 2;
  int _sampleRate = 0;
  late double _size;
  @override
  void initState() {
    super.initState();
    _startLoop = widget.startLoop;
    _endLoop = widget.endLoop;
    _totalSamples = widget.totalSamples;
    _sampleRate = widget.sampleRate;
    _size = widget.size;
    setState(() {});
  }

  void filechanged(BRSTM brstm) {
    brstm.open();
    brstm.readSync();
    setState(() {
      _totalSamples = brstm.getTotalSamples()!;
      _startLoop = brstm.getLoopStart()!;
      _endLoop = brstm.getLoopEnd()!;
      _sampleRate = brstm.getSampleRate()!;
    });
  }

  void updateSize(double value) {
    _size = value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_startLoop ~/ _sampleRate),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore minimo
                Text(
                  formatDuration(_endLoop ~/ _sampleRate),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore massimo in minuti
              ],
            ),
          ),
          RangeSlider(
            activeColor: Colors.amberAccent,
            inactiveColor: Colors.white38,
            min: 0.0,
            max: _totalSamples.toDouble(),
            values: RangeValues(_startLoop.toDouble(), _endLoop.toDouble()),
            onChanged: (values) {
              setState(() {
                _startLoop = values.start.toInt();
                _endLoop = values.end.toInt();
              });
            },
            // onChangeEnd: (value) {
            //   // Chiamato quando l'utente rilascia lo slider
            //   widget.onSeek(value); // Aggiorna la posizione della canzone
            // },
          ),
        ],
      ),
    );
  }
}
