import 'package:flutter/material.dart';
import 'package:musicdemo/demo.dart';
import 'package:musicdemo/demos/animated_player.dart';

class DemoList extends StatelessWidget {
  const DemoList({Key? key}) : super(key: key);

  final List<Demo> demos = const [
    Demo(
      title: "Animated Player",
      page: AnimatedPlayer(),
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        List.generate(
          demos.length,
          (index) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnimatedPlayer()));
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    demos[index].title,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
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
