import 'package:flashy_flutter/widgets/option_pill.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

import '../models/deck_data.dart';

class DeckCard extends StatelessWidget {

  final DeckData deckData;
  final void Function(int) onUserTap;

  const DeckCard({
    super.key,
    required this.deckData,
    required this.onUserTap,
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
          Text(
            deckData.name,
            style: const TextStyle(
              color: black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )
          ),
          const SizedBox(height: 2),
          Text(
            deckData.description,
            style: const TextStyle(
              color: gray,
              fontSize: 12
            )
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () { onUserTap(deckData.id); },
                child: Row(
                  children: [
                    (deckData.creator.profileImage != null) ? CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(deckData.creator.profileImage!),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading image: $exception');
                      },
                    ) : const Icon(
                        Icons.account_circle,
                        size: 20,
                        color: gray2
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deckData.creator.name,
                      style: const TextStyle(
                        color: gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.thumb_up,
                size: 14,
                color: gray,
              ),
              const SizedBox(width: 4),
              Text(
                deckData.likedUsers.length.toString(),
                style: const TextStyle(
                  color: gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  OptionPill(color: 'red', text: deckData.leftOption),
                  SizedBox(width: 6),
                  OptionPill(color: 'green', text: deckData.rightOption)
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
