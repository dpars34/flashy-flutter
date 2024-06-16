import 'user_data.dart';

class HighscoresData {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int deckId;
  final int userId;
  final double time;
  final User user;

  HighscoresData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deckId,
    required this.userId,
    required this.time,
    required this.user,
  });

  factory HighscoresData.fromJson(Map<String, dynamic> json) {
    return HighscoresData(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deckId: json['deck_id'],
      userId: json['user_id'],
      time: json['time'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deck_id': deckId,
      'user_id': userId,
      'time': time,
      'user': user.toJson(),
    };
  }
}