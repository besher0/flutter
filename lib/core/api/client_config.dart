typedef FromJson<T> = T Function(dynamic json);

class RequestConfig<T> {
  late final dynamic queryParameters;
  late final dynamic data;
  late final String endpoint;
  late final ResponseValue<T> response;
  final Duration? receiveTimeout;
  final Duration? sendTimeout;
  RequestConfig({
    required this.endpoint,
    required this.response,
    this.queryParameters,
    this.data,
    this.receiveTimeout,
    this.sendTimeout,
  });
}

class ResponseValue<T> {
  final T? returnValueOnSuccess;
  final FromJson<T>? fromJson;

  ResponseValue({this.returnValueOnSuccess, this.fromJson})
    : assert(() {
        if (fromJson == null && returnValueOnSuccess == null) {
          return false;
        }
        return true;
      }(), "They cannot both have a null value together");
}
