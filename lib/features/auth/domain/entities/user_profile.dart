class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'Unknown User',
      photoUrl: map['photoUrl'],
    );
  }
}
