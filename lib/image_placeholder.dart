import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          "https://loremflickr.com/150/150?$key",
          width: 150.0,
          height: 150.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
