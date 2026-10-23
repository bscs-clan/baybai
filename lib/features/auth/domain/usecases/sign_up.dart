import "package:baybai/features/auth/domain/repositories/auth_repository.dart";

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _repository.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }
}
