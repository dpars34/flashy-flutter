import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/models/highscores_data.dart';
import 'package:intl/intl.dart';

class LeaderboardCard extends StatelessWidget {

  final List<HighscoresData> highscoresData;
  final int? highlightIndex;

  const LeaderboardCard({
    super.key,
    required this.highscoresData,
    required this.highlightIndex
  });

  String formatTime(int timeInMilliseconds) {
    final int minutes = timeInMilliseconds ~/ 60000; // 1 minute = 60000 milliseconds
    final int seconds = (timeInMilliseconds % 60000) ~/ 1000; // 1 second = 1000 milliseconds
    final int milliseconds = (timeInMilliseconds % 1000) ~/ 10; // Get hundredths of a second

    final String formattedMinutes = minutes.toString();
    final String formattedSeconds = seconds.toString().padLeft(2, '0');
    final String formattedMilliseconds = milliseconds.toString().padLeft(2, '0');

    return "$formattedMinutes:$formattedSeconds.$formattedMilliseconds";
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
                  style: TextStyle(
                    color: highlightIndex == index ? primary : gray,
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
