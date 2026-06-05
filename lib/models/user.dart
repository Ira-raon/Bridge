class AppUser {
  final String id;
  final String email;
  final String? displayName;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });
}