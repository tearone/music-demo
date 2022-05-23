import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:musicdemo/demos/animated_player/player.dart';
import 'package:musicdemo/utils.dart';

class PlayerExpandedSlider extends StatefulWidget {
  const PlayerExpandedSlider({Key? key}) : super(key: key);

  @override
  State<PlayerExpandedSlider> createState() => _PlayerExpandedSliderState();
}

class _PlayerExpandedSliderState extends State<PlayerExpandedSlider> {
  double progress = 0.0;
  double lastProgress = 0.0;
  bool isChanging = false;

  late List<int> waveform;

  @override
  void initState() {
    super.initState();
    waveform = List.generate(100, (index) => Random().nextInt(50) + 5);
  }

  @override
  Widget build(BuildContext context) {
    final dProgress = progress;

    return SizedBox(
      height: 65.0,
      child: FlutterSlider(
        min: 0.0,
        max: 1.0,
        step: const FlutterSliderStep(
          step: 0.001,
          isPercentRange: true,
        ),
        values: [dProgress],
        handler: FlutterSliderHandler(
          decoration: const BoxDecoration(),
          child: Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(3),
              //   color: Colors.white,
              //   border: Border.all(color: Colors.black.withOpacity(0.65), width: 1),
              // ),
              ),
        ),
        handlerWidth: 5.0,
        handlerHeight: 40.0,
        touchSize: 20.0,
        tooltip: FlutterSliderTooltip(
          disableAnimation: true, // disabled because looked buggy
          custom: (_) => Text.rich(
            TextSpan(
              text: "03:10",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isChanging ? Colors.white.withOpacity(.75) : Colors.transparent,
              ),
            ),
          ),
          boxStyle: const FlutterSliderTooltipBox(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        ),
        hatchMark: FlutterSliderHatchMark(
          labels: _updateEffects(dProgress * waveform.length),
          linesAlignment: FlutterSliderHatchMarkAlignment.right,
          density: 0.5,
        ),
        trackBar: const FlutterSliderTrackBar(
          activeTrackBar: BoxDecoration(color: Colors.transparent),
          inactiveTrackBar: BoxDecoration(color: Colors.transparent),
        ),
        onDragStarted: (a, b, c) {
          isChanging = true;
          setState(() => progress = b);
        },
        onDragCompleted: (a, b, c) {
          isChanging = false;
        },
        onDragging: (a, b, c) {
          setState(() => progress = b);
          if ((lastProgress - progress).abs() > 1 / waveform.length) {
            HapticFeedback.mediumImpact();
            lastProgress = progress;
          }
        },
      ),
    );
  }

  List<FlutterSliderHatchMarkLabel> _updateEffects(double rightPercent) {
    List<FlutterSliderHatchMarkLabel> newLabels = [];
    for (int i = 0; i < waveform.length; i++) {
      var dist = (i - rightPercent).abs();

      double activeOpacity = 1.0;
      double inactiveOpacity = 0.2;
      double activeHeight = 1.0;
      double inactiveHeight = 1.0;

      if (isChanging) {
        activeOpacity = 0.5;
        inactiveOpacity = 0.1;
      }

      if (dist < 15 && isChanging) {
        activeOpacity = norm(dist, 0, 15, 1.0, 0.5);
        inactiveOpacity = norm(dist, 0, 15, 0.2, 0.1);
      }

      if (dist < 15 && isChanging) {
        activeHeight = norm(dist, 0, 15, 1.75, 1.0);
        inactiveHeight = norm(dist, 0, 15, 1.25, 1.0);
      }

      if (i <= rightPercent) {
        newLabels.add(
          FlutterSliderHatchMarkLabel(
            percent: i.toDouble(),
            label: AnimatedContainer(
              curve: isChanging ? Curves.easeOut : Curves.linearToEaseOut,
              duration: Duration(milliseconds: isChanging ? 100 : 500),
              height: waveform[i] * activeHeight / 1.5,
              width: 2.25,
              //margin: EdgeInsets.symmetric(horizontal: w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        newLabels.add(
          FlutterSliderHatchMarkLabel(
            percent: i.toDouble(),
            label: AnimatedContainer(
              curve: isChanging ? Curves.easeOut : Curves.linearToEaseOut,
              duration: Duration(milliseconds: isChanging ? 100 : 500),
              height: waveform[i] * inactiveHeight / 1.5,
              width: 2.25,
              //margin: EdgeInsets.symmetric(horizontal: w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white.withOpacity(inactiveOpacity),
              ),
            ),
          ),
        );
      }
    }
    return newLabels;
  }
}
