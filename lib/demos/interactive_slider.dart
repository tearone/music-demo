import 'package:flutter/material.dart';
import 'package:musicdemo/demos/interactive_slider/slider.dart';

class InteractiveSliderDemo extends StatelessWidget {
  const InteractiveSliderDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: InteractiveSlider(),
        ),
      ),
    );
  }
}
