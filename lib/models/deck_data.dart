import 'dart:convert';

import 'package:flashy_flutter/models/creator_data.dart';
import 'package:flashy_flutter/models/cards_data.dart';
import 'package:flashy_flutter/models/highscores_data.dart';

import 'category_data.dart';

class DeckData {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int creatorUserId;
  final String name;
  final String description;
  final CategoryData? category;
  final String leftOption;
  final String rightOption;
  final int count;
  late final List<int> likedUsers;
  final CreatorData creator;
  final List<CardsData>? cards;
  final List<HighscoresData> highscores;

  DeckData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorUserId,
    required this.name,
    required this.description,
    required this.category,
    required this.leftOption,
    required this.rightOption,
    required this.count,
    required this.likedUsers,
    required this.creator,
    this.cards,
    required this.highscores,
  });

  factory DeckData.fromJson(Map<String, dynamic> json) {
    return DeckData(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      creatorUserId: json['creator_user_id'],
      name: json['name'],
      description: json['description'],
      category: CategoryData.fromJson(json['category']),
      leftOption: json['left_option'],
      rightOption: json['right_option'],
      count: json['count'],
      likedUsers: List<int>.from(json['liked_users']),
      creator: CreatorData.fromJson(json['creator']),
      cards: json['cards'] != null
          ? (json['cards'] as List).map((i) => CardsData.fromJson(i)).toList()
          : null,
      highscores: (json['highscores'] as List).map((i) => HighscoresData.fromJson(i)).toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator_user_id': creatorUserId,
      'name': name,
      'description': description,
      'category': category,
      'left_option': leftOption,
      'right_option': rightOption,
      'count': count,
      'liked_users': likedUsers,
      'creator': creator.toJson(),
      'cards': cards?.map((e) => e.toJson()).toList(),
      'highscores': highscores?.map((e) => e.toJson()).toList(),
    };
  }

  DeckData copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? creatorUserId,
    String? name,
    String? description,
    CategoryData? category,
    String? leftOption,
    String? rightOption,
    int? count,
    List<int>? likedUsers,
    CreatorData? creator,
    List<CardsData>? cards,
    List<HighscoresData>? highscores,
  }) {
    return DeckData(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      leftOption: leftOption ?? this.leftOption,
      rightOption: rightOption ?? this.rightOption,
      count: count ?? this.count,
      likedUsers: likedUsers ?? this.likedUsers,
      creator: creator ?? this.creator,
      cards: cards ?? this.cards,
      highscores: highscores ?? this.highscores,
    );
  }
}