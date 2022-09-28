import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musicdemo/demos/animated_player/horizontal_showcase.dart';
import 'package:musicdemo/demos/animated_player/player.dart';
import 'package:musicdemo/image_color.dart';

class AnimatedPlayerDemo extends StatefulWidget {
  const AnimatedPlayerDemo({Key? key}) : super(key: key);

  @override
  State<AnimatedPlayerDemo> createState() => _AnimatedPlayerDemoState();
}

class _AnimatedPlayerDemoState extends State<AnimatedPlayerDemo> with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 2.1,
      lowerBound: -0.1,
      value: 0.0,
    );
  }

  Future<Uint8List> getImage() async {
    final res = await http.get(Uri.parse("https://random.imagecdn.app/500/500"));
    return res.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: getImage(),
      builder: (context, snapshot) {
        final colors = snapshot.hasData ? generateColorPalette(snapshot.data!) : [];
        final theme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: snapshot.hasData ? colors[1] : Colors.blue,
          fontFamily: "Montserrat",
        );
        return Theme(
          data: theme,
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.95, -0.95),
                  radius: 1.0,
                  colors: [
                    theme.colorScheme.onSecondary.withOpacity(.4),
                    theme.colorScheme.onSecondary.withOpacity(.2),
                  ],
                ),
              ),
              child: Stack(
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
                    child: MediaQuery(
                      data: MediaQuery.of(context).removePadding(removeTop: true),
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
                  ),

                  /// Background blur
                  // Positioned.fill(
                  //   child: AnimatedBuilder(
                  //     animation: animation,
                  //     builder: (context, child) {
                  //       return BackdropFilter(
                  //         filter: ImageFilter.blur(
                  //           sigmaX: 16.0 * animation.value,
                  //           sigmaY: 16.0 * animation.value,
                  //         ),
                  //         child: Container(),
                  //       );
                  //     },
                  //   ),
                  // ),

                  /// Opacity
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Container(
                          color: Colors.black.withOpacity((animation.value * 1.2).clamp(0, 1)),
                          child: Container(
                            color: Theme.of(context).colorScheme.onSecondary.withOpacity((animation.value * 3 - 2).clamp(0, .45)),
                          ),
                        );
                      },
                    ),
                  ),

                  /// Miniplayer
                  if (snapshot.hasData) Positioned.fill(child: Player(animation: animation, mainImageBytes: snapshot.data!)),

                  // if (snapshot.hasData)
                  //   SafeArea(
                  //     child: Row(
                  //       children: List.generate(
                  //         colors.length,
                  //         (index) => Container(
                  //           padding: const EdgeInsets.all(12.0),
                  //           child: Container(
                  //             color: colors[index],
                  //             height: 100,
                  //             width: 100,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
