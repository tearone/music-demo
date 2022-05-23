import 'package:flutter/material.dart';
import 'package:musicdemo/utils.dart';

class TrackInfo extends StatelessWidget {
  const TrackInfo({
    Key? key,
    required this.animation,
    required this.title,
    required this.artist,
  }) : super(key: key);

  final Animation animation;
  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: vp(a: 18.0, b: 36.0, c: animation.value),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    artist,
                    style: TextStyle(
                      fontSize: vp(a: 16.0, b: 24.0, c: animation.value),
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: (animation.value * 10 - 9).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(-100 * (1.0 - animation.value.clamp(0.0, 1.0)), 0.0),
                child: IconButton(
                  onPressed: () {},
                  iconSize: 34.0,
                  icon: Icon(Icons.favorite_border),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
