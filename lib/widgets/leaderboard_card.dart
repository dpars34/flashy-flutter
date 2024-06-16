import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/models/highscores_data.dart';

class LeaderboardCard extends StatelessWidget {

  final List<HighscoresData> highscoresData;

  const LeaderboardCard({
    super.key,
    required this.highscoresData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATA GOES HERE')
        ],
      ),
    );
  }
}
