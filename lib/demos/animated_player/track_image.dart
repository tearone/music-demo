import 'package:flutter/material.dart';
import 'package:musicdemo/image_placeholder.dart';
import 'package:musicdemo/utils.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    required this.image,
    required this.bottomOffset,
    required this.maxOffset,
    required this.screenSize,
    required this.cp,
    required this.p,
    this.large = false,
  }) : super(key: key);

  final String image;
  final bool large;

  final double bottomOffset;
  final double maxOffset;
  final Size screenSize;
  final double cp;
  final double p;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, bottomOffset + (-maxOffset / 2.2 * p.clamp(0, 2))),
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
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ImagePlaceholder(key: Key(image), large: large),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
