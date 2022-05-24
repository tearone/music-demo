import 'package:flutter/material.dart';
import 'package:musicdemo/demos/animated_player/queue_tile.dart';

class QueueView extends StatelessWidget {
  const QueueView({Key? key, this.controller}) : super(key: key);

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        controller: controller,
        itemCount: 50,
        itemBuilder: (context, index) {
          return const QueueTile();
        },
      ),
    );
  }
}
