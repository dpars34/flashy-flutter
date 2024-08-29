class CreatorData {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreatorData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreatorData.fromJson(Map<String, dynamic> json) {
    return CreatorData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'] != null
          ? (json['profile_image'])
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}