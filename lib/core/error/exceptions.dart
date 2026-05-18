class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class CacheException extends AppException {
  const CacheException(super.message);
}
