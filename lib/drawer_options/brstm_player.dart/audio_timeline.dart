import 'dart:async';

import 'package:brstm_player/brstm.dart';
import 'package:flutter/material.dart';

class AudioTimeline extends StatefulWidget {
  final double currentPosition;
  final double duration;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;

  final ValueChanged<double> onLoopPointChange;
  final double size;
  final int loopPointStart;
  final int loopPointEnd;
  final int sampleRate;
  final Function onLoopPointReached;

  const AudioTimeline({
    required this.currentPosition,
    required this.duration,
    required this.onSeek,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.loopPointStart,
    required this.loopPointEnd,
    required this.onLoopPointReached,
    required this.onLoopPointChange,
    required this.size,
    required this.sampleRate,
    Key? key,
  }) : super(key: key);
  @override
  State<AudioTimeline> createState() => AudioTimelineState();
}

class AudioTimelineState extends State<AudioTimeline> {
  double sliderValue = 0.0;
  double _fileDuration = 0.0;
  int _loopStart = 0;
  int _loopEnd = 0;
  int _sampleRate = 0;
  late double _size;
  bool isPlaying = false;
  late Timer _timer;
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _timerFunc() async {
    if (!mounted) {
      _timer.cancel();
      return;
    }

    if (isPlaying) {
      if (sliderValue * _sampleRate < _loopEnd) {
        sliderValue += 1.0;
      }

      if (sliderValue * _sampleRate >= _loopEnd) {
        widget.onLoopPointReached();
        setState(() {
          sliderValue = _loopStart / _sampleRate;
        });
      }
    }
  }

  void filechanged(BRSTM brstm) {
    isPlaying = false;
    brstm.open();
    brstm.readSync();
    setState(() {
      _fileDuration = brstm.getDuration()!;
      _loopStart = brstm.getLoopStart()!;
      _loopEnd = brstm.getLoopEnd()!;
      _sampleRate = brstm.getSampleRate()!;
    });
  }

  void updateSize(double value) {
    _size = value;
  }

  void updateLoopPoint(int loopPoint) {
    _loopStart = loopPoint;
  }

  @override
  void initState() {
    super.initState();
    _size = widget.size;
    sliderValue = widget.currentPosition;
    _fileDuration = widget.duration;
    _loopStart = widget.loopPointStart;
    _loopEnd = widget.loopPointEnd;
    _sampleRate = widget.sampleRate;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _timerFunc();
      setState(() {});
    });
  }

  void togglePlay() {
    isPlaying = !isPlaying;

    if (!mounted) {
      _timer.cancel();
      return;
    }
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
                  formatDuration(sliderValue.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore minimo
                Text(
                  formatDuration(_fileDuration.toInt()),
                  style: const TextStyle(color: Colors.white70),
                ), // Aggiungi il testo per il valore massimo in minuti
              ],
            ),
          ),
          Slider(
            min: 0.0,
            max: _fileDuration > 0 ? _fileDuration : 999,
            value: sliderValue > _fileDuration ? 0 : sliderValue,
            onChangeStart: (value) async => {widget.onChangeStart(value)},
            onChanged: (value) {
              //_sliderValue = value;

              widget.onSeek(value);
              setState(() {
                sliderValue = value;
              });
            },
            onChangeEnd: (value) async => {
              widget.onChangeEnd(value),
              setState(() {
                sliderValue = value;
              })
            },
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
