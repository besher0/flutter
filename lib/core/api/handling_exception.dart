import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../enums/status_code_type.dart';
import '../error/exception.dart';
import '../error/failures.dart';

typedef RequestCall<T> = Future<T> Function();

mixin HandlingExceptionRequest {
  void prettyPrinterError(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).e(message);
  }

  void prettyPrinterWtf(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).wtf(message);
  }

  void prettyPrinterI(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).i(message);
  }

  void prettyPrinterV(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).v(message);
  }

  Exception getException({required int statusCode, String? message}) {
    if (statusCode == StatusCode.operationFailed.code) {
      return OperationFailedException(message: message);
    } else {
      return ServerException(message: message);
    }
  }

  Future<Either<Failure, T>> handlingExceptionRequest<T>({
    required RequestCall<T> tryCall,
  }) async {
    try {
      T response = await tryCall();
      return Right(response);
    } on ServerException catch (e) {
      // Fluttertoast.showToast(msg: 'assas_appsss',backgroundColor: Colors.yellow);
      prettyPrinterError("***|| ServerException ||*** ");
      return Left(ServerFailure("ServerException", message: e.message));
    } on DioException catch (e, s) {
      // Fluttertoast.showToast(msg: 'aaaaaaaaaaaa',backgroundColor: Colors.yellow);

      prettyPrinterError("***|| DioError ||*** \n $s");
      return Left(
        e.response?.statusCode == 404
            ? NotFoundFailure()
            : e.response?.statusCode == 401
            ? UnAuthorizedFailure(
                message: (e.response == null
                    ? e.response.toString()
                    : e.response?.data['message'] ??
                          e.response?.data['result'] ??
                          e.response?.data['error'] ??
                          e.response?.data['errors'][0]['msg']),
              )
            : DioFailure(
                message:
                    (e.response == null
                            ? e.response.toString()
                            : e.response?.data['message'] ??
                                  e.response?.data['result'] ??
                                  e.response?.data['error'] ??
                                  e.response?.data['errors'][0]['msg'])
                        .toString(),
              ),
      );
    } catch (e, stackTrace) {
      prettyPrinterError(
        "***|| CATCH ERROR ||***"
        "\n $e"
        "***|| Stack Trace ||***"
        "\n $stackTrace",
      );
      return Left(ServerFailure("ServerException", message: e.toString()));
    }
  }
}
