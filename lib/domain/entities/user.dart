class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;

  /// Profile photo from the Google account; null for email accounts.
  final String? avatarUrl;
}
