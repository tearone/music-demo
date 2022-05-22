import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicdemo/image_placeholder.dart';

class Player extends StatefulWidget {
  const Player({Key? key, required this.animation}) : super(key: key);

  final AnimationController animation;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  double offset = 0.0;
  double prevOffset = 0.0;
  late Size screenSize;
  late double maxOffset;

  @override
  void initState() {
    super.initState();
    screenSize = MediaQueryData.fromWindow(window).size;
    maxOffset = screenSize.height;
  }

  void snapToTop() {
    offset = maxOffset;
    widget.animation.animateTo(
      1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
  }

  void snapToBottom() {
    offset = 0;
    widget.animation.animateTo(
      0.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.animation.value == 0) {
          snapToTop();
        }
      },
      onVerticalDragStart: (details) {
        prevOffset = offset;
      },
      onVerticalDragUpdate: (details) {
        offset -= details.primaryDelta ?? 0;
        offset = offset.clamp(0, maxOffset);
        widget.animation.animateTo(percentageFromValueInRange(min: 0, max: maxOffset, value: offset), duration: Duration.zero);
      },
      onVerticalDragEnd: (details) {
        const actuationOffset = 100.0; // min distance to snap
        bool snapFull;

        if (prevOffset > maxOffset / 2) {
          if (prevOffset - offset > actuationOffset) {
            snapFull = false;
          } else {
            snapFull = true;
          }
        } else {
          if (offset - prevOffset > actuationOffset) {
            snapFull = true;
          } else {
            snapFull = false;
          }
        }

        if (snapFull) {
          snapToTop();
        } else {
          snapToBottom();
        }
      },
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          final double p = widget.animation.value;
          final double cp = p.clamp(0, 1);

          return Stack(
            children: [
              // Player Body
              Container(
                color: p > 0 ? Colors.transparent : null,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, -96 * (1 - cp) + p.clamp(-1, 0) * -200),
                    child: Container(
                      color: Colors.transparent, // prevents scrolling gap
                      child: Padding(
                        padding: EdgeInsets.all((12.0 * (1 - p)).clamp(0.0, 12.0)),
                        child: Container(
                          height: vp(a: 82.0, b: maxOffset / 1.6, c: p.clamp(0, 2)),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.0 + 6.0 * p),
                              topRight: Radius.circular(24.0 + 6.0 * p),
                              bottomLeft: Radius.circular(24.0 * (1 - p)),
                              bottomRight: Radius.circular(24.0 * (1 - p)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Top Row
              Opacity(
                opacity: cp,
                child: Transform.translate(
                  offset: Offset(0, (1 - p) * -100),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              snapToBottom();
                            },
                            icon: const Icon(Icons.expand_more),
                            iconSize: 32.0,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("Playing from", style: TextStyle(color: Colors.white70)),
                              Text(
                                "Fuzet",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert),
                            iconSize: 26.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Slider
              Opacity(
                opacity: (cp * 10 - 9).clamp(0, 1),
                child: Transform.translate(
                  offset: Offset(0, (-96 * (1 - cp) + p.clamp(-1, 0) * -200) + (-screenSize.height / 4.5 * p.clamp(0, 2))),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 42.0,
                          child: Slider(
                            value: 0.35,
                            onChanged: (_) {},
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("3:12"),
                              Text("1:31"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Controls
              Transform.translate(
                offset: Offset(0, (-96 * (1 - cp) + p.clamp(-1, 0) * -200) + (-screenSize.height / 10.0 * p.clamp(0, 2))),
                child: Padding(
                  padding: EdgeInsets.all(12.0 * (1 - cp)),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Opacity(
                          opacity: (cp * 10 - 9).clamp(0, 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0 * (24 * (1 - cp) + 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(icon: const Icon(Icons.shuffle), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
                              ],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: (cp * 10 - 9).clamp(0, 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 84.0 * (2 * (1 - cp) + 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(iconSize: 32.0, icon: const Icon(Icons.skip_previous), onPressed: () {}),
                                IconButton(iconSize: 32.0, icon: const Icon(Icons.skip_next), onPressed: () {}),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.only(right: screenSize.width * cp / 2 - 80 * cp / 2)),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              floatingActionButtonTheme: FloatingActionButtonThemeData(
                                sizeConstraints: BoxConstraints.tight(Size.square(vp(a: 60.0, b: 80.0, c: p))),
                                iconSize: vp(a: 32.0, b: 42.0, c: p),
                              ),
                            ),
                            child: FloatingActionButton(
                              onPressed: () {},
                              elevation: 0,
                              backgroundColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(.25),
                              child: const Icon(Icons.pause),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Track Info
              Transform.translate(
                offset: Offset(0, (-96 * (1 - cp) + p.clamp(-1, 0) * -200) + (-screenSize.height / 4 * p.clamp(0, 2))),
                child: Padding(
                  padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.only(left: 24.0 * cp)),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: vp(a: 82.0, b: screenSize.width / 2, c: cp),
                      child: Row(
                        children: [
                          SizedBox(width: 82.0 * (1 - cp)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "akactea",
                                style: TextStyle(
                                  fontSize: vp(a: 18.0, b: 36.0, c: p),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "pataki",
                                style: TextStyle(
                                  fontSize: vp(a: 16.0, b: 24.0, c: p),
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Track Image
              Transform.translate(
                offset: Offset(0, (-96 * (1 - cp) + p.clamp(-1, 0) * -200) + (-screenSize.height / 2.2 * p.clamp(0, 2))),
                child: Padding(
                  padding: EdgeInsets.all(12.0 * (1 - cp)).add(EdgeInsets.only(left: 42.0 * cp)),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: vp(a: 82.0, b: screenSize.width - 84.0, c: cp),
                      child: Padding(
                        padding: EdgeInsets.all(12.0 * (1 - cp)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(vp(a: 18.0, b: 24.0, c: cp)),
                          child: const AspectRatio(
                            aspectRatio: 1,
                            child: ImagePlaceholder(large: true),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

double vp({
  required final double a,
  required final double b,
  required final double c,
}) {
  return c * (b - a) + a;
}

double percentageFromValueInRange({
  required final double min,
  required final double max,
  required final double value,
}) {
  return (value - min) / (max - min);
}

double normalizeBetweenTwoRanges(double val, double minVal, double maxVal, double newMin, double newMax) {
  return newMin + (val - minVal) * (newMax - newMin) / (maxVal - minVal);
}
