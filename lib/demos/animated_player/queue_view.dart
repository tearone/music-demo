import 'package:flutter/material.dart';
import 'package:musicdemo/demos/animated_player/queue_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(38.0), topRight: Radius.circular(38.0)),
          child: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: 12.0);
              }
              index = index - 1;
              return const QueueTile();
            },
          ),
        ),
      ),
    );
  }
}
