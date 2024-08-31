class ProfileData {
  final int id;
  final String name;
  final String bio;
  final String? profileImage;
  final DateTime createdAt;

  ProfileData({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileImage,
    required this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      name: json['name'],
      bio: json['bio'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}