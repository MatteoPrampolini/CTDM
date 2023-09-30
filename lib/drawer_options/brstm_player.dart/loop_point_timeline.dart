import 'package:brstm_player/brstm.dart';
import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';

class LoopPointTimeline extends StatefulWidget {
  final int startLoop;
  final int endLoop;
  final int sampleRate;
  final double size;
  final ValueChanged<double> onLoopPointChange;
  final ValueChanged<double> onLoopPointChangeEnd;

  const LoopPointTimeline({
    required this.startLoop,
    required this.endLoop,
    required this.sampleRate,
    required this.onLoopPointChange,
    required this.onLoopPointChangeEnd,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  State<LoopPointTimeline> createState() => LoopPointTimelineState();
}

class LoopPointTimelineState extends State<LoopPointTimeline> {
  int _startLoop = 0;
  int _endLoop = 1;
  int _sampleRate = 0;
  late double _size;
  @override
  void initState() {
    super.initState();
    _startLoop = widget.startLoop;
    _endLoop = widget.endLoop;
    _sampleRate = widget.sampleRate;
    _size = widget.size;
    setState(() {});
  }

  void filechanged(BRSTM brstm) {
    brstm.open();
    brstm.readSync();
    setState(() {
      _startLoop = brstm.getLoopStart()!;
      _endLoop = brstm.getLoopEnd()!;
      _sampleRate = brstm.getSampleRate()!;
    });
  }

  void updateLoopPoint(int loopPoint) {
    _startLoop = loopPoint;
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
          Slider(
            inactiveColor: Colors.amberAccent,
            activeColor: Colors.white38,
            thumbColor: Colors.amberAccent,
            min: 0.0,
            max: _endLoop.toDouble(),
            value: _startLoop.toDouble(),
            onChanged: (value) {
              setState(() {
                _startLoop = value.toInt();

                widget.onLoopPointChange(value);
              });
            },
            onChangeEnd: (values) {
              // Chiamato quando l'utente rilascia lo slider
              widget.onLoopPointChangeEnd(
                  values); // Aggiorna la posizione della canzone
            },
          ),
        ],
      ),
    );
  }
}
