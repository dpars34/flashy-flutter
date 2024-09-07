import 'package:flashy_flutter/models/cards_data.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/models/flashy_swipe_item.dart';

class SwipeCard extends StatelessWidget {
  final CardsData item;

  SwipeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        return Container(
          width: width,
          height: width,
          child: Card(
            surfaceTintColor: white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(item.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: black,
                    )
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}