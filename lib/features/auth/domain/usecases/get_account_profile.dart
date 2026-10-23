import "package:baybai/features/auth/domain/entities/account_profile.dart";
import "package:baybai/features/auth/domain/repositories/auth_repository.dart";

class GetAccountProfile {
  const GetAccountProfile(this._repository);

  final AuthRepository _repository;

  Future<AccountProfile?> call() => _repository.getAccountProfile();
}
