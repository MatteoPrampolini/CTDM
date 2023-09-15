import 'dart:async';

import 'package:flutter/material.dart';

class AudioTimeline extends StatefulWidget {
  final double currentPosition;
  final double duration;
  final ValueChanged<double> onSeek;
  final double loopPoint;
  final ValueChanged<double> onLoopPointChange;

  const AudioTimeline({
    required this.currentPosition,
    required this.duration,
    required this.onSeek,
    required this.loopPoint,
    required this.onLoopPointChange,
    Key? key,
  }) : super(key: key);
  @override
  State<AudioTimeline> createState() => AudioTimelineState();
}

class AudioTimelineState extends State<AudioTimeline> {
  double sliderValue = 0.0;

  bool isPlaying = false;
  late Timer _timer;

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    sliderValue = widget.currentPosition;
  }

  void togglePlay() {
    isPlaying = !isPlaying;

    if (!mounted) {
      _timer.cancel();
      return;
    }
    if (isPlaying) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (!mounted) {
          _timer.cancel();
          return;
        }
        setState(() {
          if (sliderValue < widget.duration) {
            sliderValue += 1.0;

            if (sliderValue > widget.duration) {
              sliderValue = widget.duration;
            }
            widget.onSeek(sliderValue);
          }
        });
      });
    } else {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aggiorna il valore dello slider con la posizione corrente

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
                  formatDuration(sliderValue.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore minimo
                Text(
                  formatDuration(widget.duration.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore massimo in minuti
              ],
            ),
          ),
          Slider(
            min: 0.0,
            max: widget.duration,
            value: sliderValue,
            onChanged: (value) {
              //_sliderValue = value;
              widget.onSeek(value);
              setState(() {
                sliderValue = value;
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

String formatDuration(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;

  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}
