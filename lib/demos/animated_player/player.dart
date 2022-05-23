import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicdemo/demos/animated_player/slider.dart';
import 'package:musicdemo/demos/animated_player/track_image.dart';
import 'package:musicdemo/demos/animated_player/track_info.dart';
import 'package:musicdemo/music_track.dart';
import 'package:musicdemo/utils.dart';

class Player extends StatefulWidget {
  const Player({Key? key, required this.animation, required this.mainImageBytes}) : super(key: key);

  final AnimationController animation;
  final Uint8List mainImageBytes;

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
  double stParallax = 1.0;
  double siParallax = 1.15;
  static const sActuationMulti = 1.5;
  DateTime sDragStart = DateTime(0);
  late double sMaxOffset;
  late AnimationController sAnim;

  final List<MusicTrack> tracks = [
    const MusicTrack(image: "1", title: "akactea", artist: "pataki"),
    const MusicTrack(image: "2", title: "Charmy", artist: "Ekhoe"),
    const MusicTrack(image: "3", title: "Gyere Velem", artist: "AKC Kretta"),
  ];

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
    sAnim
        .animateTo(
      -1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      sOffset = 0;
      sAnim.animateTo(0.0, duration: Duration.zero);
      tracks.insert(0, tracks.removeLast());
    });
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
    sAnim
        .animateTo(
      1.0,
      curve: Curves.easeOutBack,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      sOffset = 0;
      sAnim.animateTo(0.0, duration: Duration.zero);
      tracks.add(tracks.removeAt(0));
    });
    if ((sPrevOffset - sOffset).abs() > actuationOffset) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (offset > maxOffset / 2) {
          snapToBottom();
          return false;
        }
        return true;
      },
      child: GestureDetector(
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
          sDragStart = DateTime.now();
        },
        onHorizontalDragUpdate: (details) {
          sOffset -= details.primaryDelta ?? 0.0;
          sOffset = sOffset.clamp(-sMaxOffset, sMaxOffset);
          sAnim.animateTo(sOffset / sMaxOffset, duration: Duration.zero);
        },
        onHorizontalDragEnd: (details) {
          final distance = sPrevOffset - sOffset;
          final duration = DateTime.now().difference(sDragStart);
          final speed = distance / duration.inMilliseconds / 1000;

          // speed threshold is an eyeballed value
          // used to actuate on fast flicks too

          if (speed > 0.00025 || distance > actuationOffset * sActuationMulti) {
            snapToPrev();
          } else if (-speed > 0.00025 || -distance > actuationOffset * sActuationMulti) {
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
            final BorderRadius borderRadius = BorderRadius.only(
              topLeft: Radius.circular(24.0 + 6.0 * p),
              topRight: Radius.circular(24.0 + 6.0 * p),
              bottomLeft: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
              bottomRight: Radius.circular(24.0 * (1 - p * 10 + 9).clamp(0, 1)),
            );
            final Color onSecondary = Theme.of(context).colorScheme.onSecondaryContainer;

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
                              color: Colors.black,
                              borderRadius: borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.25 * cp),
                                  blurRadius: 32.0,
                                )
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                // color: Theme.of(context).colorScheme.onSecondary,
                                borderRadius: borderRadius,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context).colorScheme.onSecondary.withOpacity(vp(a: .77, b: .9, c: 1 - cp)),
                                    Theme.of(context).colorScheme.onSecondary.withOpacity(vp(a: .5, b: .9, c: 1 - cp)),
                                  ],
                                ),
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
                if (cp != 0)
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
                                children: [
                                  Text(
                                    "Playing from",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.8),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    "Fuzet",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.0,
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
                if (cp != 0)
                  Opacity(
                    opacity: (cp * 10 - 9).clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, bottomOffset + (-maxOffset / 4.5 * p.clamp(0, 2))),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                                height: 65.0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                                  child: WaveformSlider(),
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("3:12", style: TextStyle(color: onSecondary)),
                                  Text("1:31", style: TextStyle(color: onSecondary)),
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
                    offset: Offset(0, bottomOffset + (-maxOffset / 8.5 * p.clamp(0, 2))),
                    child: Padding(
                      padding: EdgeInsets.all(12.0 * (1 - cp)),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            if (cp != 0)
                              Opacity(
                                opacity: (cp * 10 - 9).clamp(0, 1),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0 * (16 * (1 - cp) + 1)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        iconSize: 28.0,
                                        icon: Icon(Icons.shuffle, color: onSecondary),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        iconSize: 28.0,
                                        icon: Icon(Icons.repeat, color: onSecondary),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (cp != 0)
                              Opacity(
                                opacity: (cp * 10 - 9).clamp(0, 1),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 84.0 * (2 * (1 - cp) + 1)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        iconSize: 40.0,
                                        icon: Icon(Icons.skip_previous, color: onSecondary),
                                        onPressed: snapToPrev,
                                      ),
                                      IconButton(
                                        iconSize: 40.0,
                                        icon: Icon(Icons.skip_next, color: onSecondary),
                                        onPressed: snapToNext,
                                      ),
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
                                    iconSize: vp(a: 32.0, b: 46.0, c: p),
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

                // Destination selector
                if (cp != 0)
                  Opacity(
                    opacity: (cp * 10 - 9).clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, -100 * (1 - cp)),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            child: TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.headphones, size: 18.0, color: onSecondary),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14.0),
                                    child: Text('Nothing Ear 1', style: TextStyle(color: onSecondary)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Queue button
                if (cp != 0)
                  Material(
                    type: MaterialType.transparency,
                    child: Opacity(
                      opacity: (cp * 10 - 9).clamp(0, 1),
                      child: Transform.translate(
                        offset: Offset(0, -100 * (1 - cp)),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.queue_music, size: 24.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Track Info
                Material(
                  type: MaterialType.transparency,
                  child: AnimatedBuilder(
                    animation: sAnim,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Opacity(
                            opacity: -sAnim.value.clamp(-1.0, 0.0),
                            child: Transform.translate(
                              offset: Offset(-sAnim.value * sMaxOffset / stParallax - sMaxOffset / stParallax, 0),
                              child: TrackInfo(
                                  artist: tracks[0].artist,
                                  title: tracks[0].title,
                                  cp: cp,
                                  p: p,
                                  bottomOffset: bottomOffset,
                                  maxOffset: maxOffset,
                                  screenSize: screenSize),
                            ),
                          ),
                          Opacity(
                            opacity: 1 - sAnim.value.abs(),
                            child: Transform.translate(
                              offset: Offset(-sAnim.value * sMaxOffset / stParallax, 0),
                              child: TrackInfo(
                                  artist: tracks[1].artist,
                                  title: tracks[1].title,
                                  cp: cp,
                                  p: p,
                                  bottomOffset: bottomOffset,
                                  maxOffset: maxOffset,
                                  screenSize: screenSize),
                            ),
                          ),
                          Opacity(
                            opacity: sAnim.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(-sAnim.value * sMaxOffset / stParallax + sMaxOffset / stParallax, 0),
                              child: TrackInfo(
                                  artist: tracks[2].artist,
                                  title: tracks[2].title,
                                  cp: cp,
                                  p: p,
                                  bottomOffset: bottomOffset,
                                  maxOffset: maxOffset,
                                  screenSize: screenSize),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Track Image
                AnimatedBuilder(
                  animation: sAnim,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Opacity(
                          opacity: -sAnim.value.clamp(-1.0, 0.0),
                          child: Transform.translate(
                            offset: Offset(-sAnim.value * sMaxOffset / siParallax - sMaxOffset / siParallax, 0),
                            child: TrackImage(
                              image: tracks[0].image,
                              large: true,
                              p: p,
                              cp: cp,
                              screenSize: screenSize,
                              bottomOffset: bottomOffset,
                              maxOffset: maxOffset,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 1 - sAnim.value.abs(),
                          child: Transform.translate(
                            offset: Offset(-sAnim.value * sMaxOffset / siParallax, 0),
                            child: TrackImage.fromBytes(
                              bytes: widget.mainImageBytes,
                              p: p,
                              cp: cp,
                              screenSize: screenSize,
                              bottomOffset: bottomOffset,
                              maxOffset: maxOffset,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: sAnim.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(-sAnim.value * sMaxOffset / siParallax + sMaxOffset / siParallax, 0),
                            child: TrackImage(
                              image: tracks[2].image,
                              large: true,
                              p: p,
                              cp: cp,
                              screenSize: screenSize,
                              bottomOffset: bottomOffset,
                              maxOffset: maxOffset,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
