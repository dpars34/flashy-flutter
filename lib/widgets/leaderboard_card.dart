import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/models/highscores_data.dart';
import 'package:intl/intl.dart';

class LeaderboardCard extends StatelessWidget {

  final List<HighscoresData> highscoresData;

  const LeaderboardCard({
    super.key,
    required this.highscoresData,
  });

  String formatTime(double timeInSeconds) {
    final int minutes = timeInSeconds ~/ 60;
    final int seconds = (timeInSeconds % 60).toInt();
    final String formattedMinutes = NumberFormat("0").format(minutes);
    final String formattedSeconds = NumberFormat("00").format(seconds);
    return "$formattedMinutes:$formattedSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: highscoresData.asMap().entries.map((entry) {
          int index = entry.key;
          HighscoresData highscore = entry.value;
          String indexString = (index + 1).toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 25,
                  child: Text(
                    '$indexString.'
                  ),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage('https://placehold.jp/150x150.png'),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading image: $exception');
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  highscore.user.name,
                  style: const TextStyle(
                    color: gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Text(
                  formatTime(highscore.time),
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
