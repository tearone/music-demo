import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveSlider extends StatefulWidget {
  const InteractiveSlider({Key? key}) : super(key: key);

  @override
  State<InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<InteractiveSlider> {
  bool touched = false;
  bool scrubbing = false;
  double offset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        HapticFeedback.lightImpact();
        setState(() {
          offset = details.globalPosition.dx;
          scrubbing = true;
        });
      },
      onLongPressDown: (_) {
        setState(() {
          touched = true;
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          offset = details.globalPosition.dx;
        });
      },
      onLongPressEnd: (_) {
        HapticFeedback.lightImpact();
        setState(() {
          scrubbing = false;
          touched = false;
        });
      },
      onLongPressCancel: () {
        setState(() {
          scrubbing = false;
          touched = false;
        });
      },
      onHorizontalDragStart: (details) {
        HapticFeedback.lightImpact();
        setState(() {
          offset = details.globalPosition.dx;
          scrubbing = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          offset = details.globalPosition.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        HapticFeedback.lightImpact();
        setState(() {
          scrubbing = false;
          touched = false;
        });
      },
      child: AnimatedScale(
        scale: scrubbing
            ? 0.95
            : touched
                ? 0.99
                : 1.0,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: double.infinity,
            height: 72.0,
            color: Colors.white.withOpacity(.1),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: (offset - 12.0).clamp(0, 500),
                  height: double.infinity,
                  color: Colors.white.withOpacity(.1),
                ),
                Row(
                  children: [
                    const SizedBox(width: 12.0),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next),
                    ),
                    const SizedBox(width: 12.0),
                    const Text("01:32 / 04:11"),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
