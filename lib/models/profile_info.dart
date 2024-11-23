class ProfileInfo {
  final String username;
  final String name;
  final String email;

  ProfileInfo({
    required this.username,
    required this.name,
    required this.email,
  });

  factory ProfileInfo.fromMap(Map<String, dynamic> map) {
    return ProfileInfo(
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
