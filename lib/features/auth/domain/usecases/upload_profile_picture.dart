import "package:baybai/features/auth/domain/repositories/auth_repository.dart";

class UploadProfilePicture {
  const UploadProfilePicture(this._repository);

  final AuthRepository _repository;

  Future<String> call(String filePath) {
    return _repository.uploadProfilePicture(filePath);
  }
}
