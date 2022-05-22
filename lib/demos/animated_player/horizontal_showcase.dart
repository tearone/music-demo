import 'package:flutter/material.dart';
import 'package:musicdemo/image_placeholder.dart';

class HorizontalShowcase extends StatelessWidget {
  const HorizontalShowcase(this.offset, {Key? key}) : super(key: key);

  final int offset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Recently Played",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              primary: false,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox(width: 12.0);
                }

                return Card(
                  child: SizedBox(
                    width: 150.0,
                    height: 200.0,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImagePlaceholder(key: Key("${index * offset}")),
                            const SizedBox(height: 8.0),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("akactea", style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("pataki", style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
