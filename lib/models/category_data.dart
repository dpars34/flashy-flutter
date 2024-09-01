class CategoryData {
  final int id;
  final String name;
  final String emoji;

  CategoryData({
    required this.id,
    required this.name,
    required this.emoji,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
    };
  }
}