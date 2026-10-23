import "package:baybai/features/auth/domain/entities/account_profile.dart";

abstract interface class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<AccountProfile?> getAccountProfile();
  Future<String> uploadProfilePicture(String filePath);
  Future<void> signOut();
}
