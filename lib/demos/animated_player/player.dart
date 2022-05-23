import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicdemo/image_placeholder.dart';

class Player extends StatefulWidget {
  const Player({Key? key, required this.animation}) : super(key: key);

  final AnimationController animation;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with SingleTickerProviderStateMixin {
  double offset = 0.0;
  double prevOffset = 0.0;
  DateTime dragStart = DateTime(0);
  late Size screenSize;
  late double maxOffset;
  static const headRoom = 50.0;
  static const actuationOffset = 100.0; // min distance to snap

  /// Horizontal track switching
  double sOffset = 0.0;
  double sPrevOffset = 0.0;
  // DateTime sDragStart = DateTime(0);
  late double sMaxOffset;
  late AnimationController sAnim;

  @override
  void initState() {
    super.initState();
    screenSize = MediaQueryData.fromWindow(window).size;
    maxOffset = screenSize.height;
    sMaxOffset = screenSize.width;
    sAnim = AnimationController(
      vsync: this,
      lowerBound: -1,
      upperBound: 1,
      value: 0.0,
    );
  }

  void snapToTop() {
    offset = maxOffset;
    widget.animation.animateTo(
      1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
    if ((prevOffset - offset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToBottom() {
    offset = 0;
    widget.animation.animateTo(
      0.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );

    if ((prevOffset - offset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToPrev() {
    sOffset = -sMaxOffset;
    sAnim.animateTo(
      -1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToCurrent() {
    sOffset = 0;
    sAnim.animateTo(
      0.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  void snapToNext() {
    sOffset = sMaxOffset;
    sAnim.animateTo(
      1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    );
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.animation.value < (actuationOffset / maxOffset)) {
          snapToTop();
        }
      },
      onVerticalDragStart: (details) {
        prevOffset = offset;
        dragStart = DateTime.now();
      },
      onVerticalDragUpdate: (details) {
        offset -= details.primaryDelta ?? 0;
        offset = offset.clamp(-headRoom, maxOffset + headRoom);
        widget.animation.animateTo(offset / maxOffset, duration: Duration.zero);
      },
      onVerticalDragEnd: (details) {
        final duration = DateTime.now().difference(dragStart);
        final distance = prevOffset - offset;
        final speed = distance / duration.inMilliseconds / 1000;

        // speed threshold is an eyeballed value
        // used to actuate on fast flicks too

        if (prevOffset > maxOffset / 2) {
          // Start from top
          if (speed > 0.0001 || distance > actuationOffset) {
            snapToBottom();
          } else {
            snapToTop();
          }
        } else {
          // Start from bottom
          if (-speed > 0.0001 || -distance > actuationOffset) {
            snapToTop();
          } else {
            snapToBottom();
          }
        }
      },
      onHorizontalDragStart: (details) {
        sPrevOffset = sOffset;
        // sDragStart = DateTime.now();
      },
      onHorizontalDragUpdate: (details) {
        sOffset -= details.primaryDelta ?? 0.0;
        sOffset = sOffset.clamp(-sMaxOffset, sMaxOffset);
        sAnim.animateTo(sOffset / sMaxOffset, duration: Duration.zero);
      },
      onHorizontalDragEnd: (details) {
        final distance = sPrevOffset - sOffset;
        // final duration = DateTime.now().difference(sDragStart);
        // final speed = distance / duration.inMilliseconds / 1000;

        // speed threshold is an eyeballed value
        // used to actuate on fast flicks too

        if (distance > actuationOffset * 2) {
          snapToPrev();
        } else if (-distance > actuationOffset * 2) {
          snapToNext();
        } else {
          snapToCurrent();
        }
      },
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          final double p = widget.animation.value;
          final double cp = p.clamp(0, 1);
          final double bottomOffset = (-96 * (1 - cp) + p.clamp(-1, 0) * -200);

          return Stack(
            children: [
              // Player Body
              Container(
                color: p > 0 ? Colors.transparent : null, // hit test only when expanded
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, bottomOffset),
                    child: Container(
                      color: Colors.transparent, // prevents scrolling gap
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12 * (1 - cp * 10 + 9).clamp(0, 1), vertical: 12 * (1 - cp)),
                        child: Container(
                          height: vp(a: 82.0, b: maxOffset / 1.6, c: p.clamp(0, 2)),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.0 + 6.0 * p),
                              topRight: Radius.circular(24.0 + 6.0 * p),
                              bottomLeft: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
                              bottomRight: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Top Row
              //! A bug causes performance issues when pressing the icon buttons multiple times
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
                  offset: Offset(0, bottomOffset + (-maxOffset / 4.5 * p.clamp(0, 2))),
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

              /// Controls
              //! A bug causes performance issues when pressing the icon buttons multiple times
              Material(
                type: MaterialType.transparency,
                child: Transform.translate(
                  offset: Offset(0, bottomOffset + (-maxOffset / 10.0 * p.clamp(0, 2))),
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
              ),

              // Track Info
              AnimatedBuilder(
                animation: sAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-sAnim.value * sMaxOffset / 2, bottomOffset + (-maxOffset / 4 * p.clamp(0, 2))),
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
                  );
                },
              ),

              // Track Image
              AnimatedBuilder(
                animation: sAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-sAnim.value * sMaxOffset, bottomOffset + (-maxOffset / 2.2 * p.clamp(0, 2))),
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
                  );
                },
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

double pv({
  required final double min,
  required final double max,
  required final double value,
}) {
  return (value - min) / (max - min);
}

double norm(double val, double minVal, double maxVal, double newMin, double newMax) {
  return newMin + (val - minVal) * (newMax - newMin) / (maxVal - minVal);
}
