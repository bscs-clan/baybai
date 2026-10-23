class AccountProfile {
  const AccountProfile({
    required this.fullName,
    required this.email,
    this.profilePictureUrl,
  });

  final String fullName;
  final String email;
  final String? profilePictureUrl;
}
