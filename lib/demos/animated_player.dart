import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicdemo/demos/animated_player/horizontal_showcase.dart';
import 'package:musicdemo/demos/animated_player/player.dart';

class AnimatedPlayer extends StatefulWidget {
  const AnimatedPlayer({Key? key}) : super(key: key);

  @override
  State<AnimatedPlayer> createState() => _AnimatedPlayerState();
}

class _AnimatedPlayerState extends State<AnimatedPlayer> with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 1.1,
      lowerBound: -0.1,
      value: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
            children: const [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                  child: Text(
                    "Home",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 42.0),
                  ),
                ),
              ),
              HorizontalShowcase(1),
              HorizontalShowcase(2),
              HorizontalShowcase(3),
              HorizontalShowcase(4),
            ],
          ),

          // Bottom Navigation Bar
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (animation.value * 120).clamp(0, 120)),
                child: child,
              );
            },
            child: NavigationBar(
              destinations: const [
                NavigationDestination(
                  label: "Home",
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_filled),
                ),
                NavigationDestination(
                  label: "Search",
                  icon: Icon(Icons.search_outlined),
                ),
                NavigationDestination(
                  label: "Library",
                  icon: Icon(Icons.library_music_outlined),
                ),
              ],
            ),
          ),

          // Background blur
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 16.0 * animation.value,
                    sigmaY: 16.0 * animation.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),

          // Opacity
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Container(color: Colors.black.withOpacity(animation.value.clamp(0, .2)));
              },
            ),
          ),

          // Miniplayer
          Positioned.fill(child: Player(animation: animation)),
        ],
      ),
    );
  }
}
