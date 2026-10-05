class ServerException implements Exception {
  final String? message;

  ServerException({this.message = "ServerException"});
}

class OperationFailedException implements Exception {
  final String? message;

  OperationFailedException({this.message = "OperationFailedException"});
}

class TryAgainException implements Exception {
  final String? message;
  final int tryCount;

  TryAgainException({
    this.message = "TryAgainException",
    required this.tryCount,
  });
}

class NotFoundException implements Exception {
  final String? message;

  NotFoundException({this.message = "NotFoundException"});
}
