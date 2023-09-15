import 'package:ctdm/drawer_options/brstm_player.dart/audio_timeline.dart';
import 'package:flutter/material.dart';

class LoopPointTimeline extends StatefulWidget {
  final double startLoop;
  final double duration;

  final double endLoop;
  final ValueChanged<double> onLoopPointChange;

  const LoopPointTimeline({
    required this.startLoop,
    required this.duration,
    required this.endLoop,
    required this.onLoopPointChange,
    Key? key,
  }) : super(key: key);

  @override
  State<LoopPointTimeline> createState() => _LoopPointTimelineState();
}

class _LoopPointTimelineState extends State<LoopPointTimeline> {
  double _startLoop = 0;
  double _endLoop = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startLoop = widget.startLoop;
    _endLoop = widget.endLoop;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
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
                  formatDuration(_startLoop.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore minimo
                Text(
                  formatDuration(_endLoop.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore massimo in minuti
              ],
            ),
          ),
          RangeSlider(
            activeColor: Colors.amberAccent,
            inactiveColor: Colors.white38,
            min: 0.0,
            max: widget.duration,
            values: RangeValues(_startLoop, _endLoop),
            onChanged: (values) {
              setState(() {
                _startLoop = values.start;
                _endLoop = values.end;
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
