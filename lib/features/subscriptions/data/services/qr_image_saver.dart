import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

enum QrImageSaveFailure {
  accessDenied,
  network,
  notEnoughSpace,
  unsupportedFormat,
  unexpected,
}

typedef QrBytesFetcher = Future<Uint8List> Function(String url);
typedef GalleryImageWriter =
    Future<void> Function(Uint8List bytes, {required String name});

class QrImageSaveException implements Exception {
  const QrImageSaveException(this.failure, [this.cause]);

  final QrImageSaveFailure failure;
  final Object? cause;

  @override
  String toString() => 'QrImageSaveException($failure)';
}

/// Downloads a payment QR and stores it in the device photo gallery.
///
/// The fetch and write functions are injectable so the screen can be tested
/// without making a network request or invoking a platform gallery plugin.
class QrImageSaver {
  QrImageSaver({
    Dio? client,
    QrBytesFetcher? fetchBytes,
    GalleryImageWriter? galleryWriter,
  }) : _client = client ?? Dio(),
       _fetchBytes = fetchBytes,
       _galleryWriter = galleryWriter ?? _writeToGallery;

  final Dio _client;
  final QrBytesFetcher? _fetchBytes;
  final GalleryImageWriter _galleryWriter;

  Future<void> saveFromUrl({
    required String url,
    required String fileName,
  }) async {
    final bytes = await _fetch(url);
    if (bytes.isEmpty) {
      throw const QrImageSaveException(QrImageSaveFailure.unsupportedFormat);
    }

    try {
      await _galleryWriter(bytes, name: fileName);
    } on GalException catch (error) {
      throw QrImageSaveException(_mapGalleryFailure(error), error);
    } on QrImageSaveException {
      rethrow;
    } catch (error) {
      throw QrImageSaveException(QrImageSaveFailure.unexpected, error);
    }
  }

  Future<Uint8List> _fetch(String url) async {
    if (_fetchBytes != null) {
      try {
        return await _fetchBytes(url);
      } on QrImageSaveException {
        rethrow;
      } catch (error) {
        throw QrImageSaveException(QrImageSaveFailure.network, error);
      }
    }

    try {
      final response = await _client.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null) {
        throw const QrImageSaveException(QrImageSaveFailure.network);
      }
      return Uint8List.fromList(data);
    } on QrImageSaveException {
      rethrow;
    } on DioException catch (error) {
      throw QrImageSaveException(QrImageSaveFailure.network, error);
    } catch (error) {
      throw QrImageSaveException(QrImageSaveFailure.network, error);
    }
  }

  static Future<void> _writeToGallery(
    Uint8List bytes, {
    required String name,
  }) => Gal.putImageBytes(bytes, name: name);

  static QrImageSaveFailure _mapGalleryFailure(GalException error) =>
      switch (error.type) {
        GalExceptionType.accessDenied => QrImageSaveFailure.accessDenied,
        GalExceptionType.notEnoughSpace => QrImageSaveFailure.notEnoughSpace,
        GalExceptionType.notSupportedFormat =>
          QrImageSaveFailure.unsupportedFormat,
        GalExceptionType.unexpected => QrImageSaveFailure.unexpected,
      };
}
