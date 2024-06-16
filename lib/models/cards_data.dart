class CardsData {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String text;
  final String? note;
  final String answer;
  final int deckId;

  CardsData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.text,
    required this.note,
    required this.answer,
    required this.deckId,
  });

  factory CardsData.fromJson(Map<String, dynamic> json) {
    return CardsData(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      text: json['text'],
      note: json['note'],
      answer: json['answer'],
      deckId: json['deck_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'text': text,
      'note': note,
      'answer': answer,
      'deck_id': deckId,
    };
  }
}