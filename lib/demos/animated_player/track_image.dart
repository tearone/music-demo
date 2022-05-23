import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:musicdemo/image_placeholder.dart';
import 'package:musicdemo/utils.dart';

class TrackImage extends StatelessWidget {
  const TrackImage({
    Key? key,
    this.image,
    required this.bottomOffset,
    required this.maxOffset,
    required this.screenSize,
    required this.cp,
    required this.p,
    this.bytes,
    this.large = false,
  }) : super(key: key);

  factory TrackImage.fromBytes({
    required Size screenSize,
    required double bottomOffset,
    required double maxOffset,
    required double cp,
    required double p,
    required Uint8List bytes,
  }) {
    return TrackImage(bytes: bytes, bottomOffset: bottomOffset, maxOffset: maxOffset, screenSize: screenSize, cp: cp, p: p);
  }

  final String? image;
  final bool large;

  final double bottomOffset;
  final double maxOffset;
  final Size screenSize;
  final double cp;
  final double p;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(vp(a: 18.0, b: 24.0, c: cp));

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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25 * cp),
                      blurRadius: 24.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: bytes != null ? Image.memory(bytes!) : ImagePlaceholder(key: Key(image ?? "default"), large: large),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
