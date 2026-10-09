import 'package:coursaty_student_and_teacher/core/storage/prefs_repository.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/encrypted_hls_download_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a different account on the same installation clears the previous downloads', () async {
    final downloads = _FakeDownloadService();
    final bloc = MyDownloadsBloc(_Prefs(userId: null), downloads);
    bloc.emit(
      MyDownloadsState(
        ownerUserId: 'user-A',
        urlToFileReferences: const {'video-1': 'secure-hls://video-1'},
      ),
    );

    bloc.add(SyncDownloadsOwner('user-B'));
    await settle();

    expect(downloads.deleted, ['video-1']);
    expect(bloc.state.urlToFileReferences, isEmpty);
    expect(bloc.state.ownerUserId, 'user-B');
    await bloc.close();
  });

  test('signing back in with the same account keeps downloads', () async {
    final downloads = _FakeDownloadService();
    final bloc = MyDownloadsBloc(_Prefs(userId: null), downloads);
    bloc.emit(
      MyDownloadsState(
        ownerUserId: 'user-A',
        urlToFileReferences: const {'video-1': 'secure-hls://video-1'},
      ),
    );

    bloc.add(SyncDownloadsOwner('user-A'));
    await settle();

    expect(downloads.deleted, isEmpty);
    expect(bloc.state.urlToFileReferences, hasLength(1));
    await bloc.close();
  });

  test('state saved before ownership existed is adopted, not wiped', () async {
    final downloads = _FakeDownloadService();
    final bloc = MyDownloadsBloc(_Prefs(userId: null), downloads);
    bloc.emit(
      MyDownloadsState(
        urlToFileReferences: const {'video-1': 'secure-hls://video-1'},
      ),
    );

    bloc.add(SyncDownloadsOwner('user-A'));
    await settle();

    expect(downloads.deleted, isEmpty);
    expect(bloc.state.ownerUserId, 'user-A');
    await bloc.close();
  });

  test('ownership survives hydration', () {
    final restored = MyDownloadsState.fromJson(
      MyDownloadsState(ownerUserId: 'user-A').toJson(),
    );
    expect(restored.ownerUserId, 'user-A');
  });
}

class _FakeDownloadService implements EncryptedHlsDownloadService {
  final deleted = <String>[];

  @override
  Future<void> deleteVideo(String videoId) async => deleted.add(videoId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PrefsRepository {
  _Prefs({required this.userId});

  @override
  final String? userId;

  @override
  bool get isGuest => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MemoryStorage implements Storage {
  final _values = <String, dynamic>{};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}
