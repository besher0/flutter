import 'package:coursaty_student_and_teacher/core/utils/debouncer.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/widgets/search_with_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Records the search queries sent to the bloc.
class _RecordingHomeBloc extends Bloc<HomeEvent, HomeState>
    implements HomeBloc {
  _RecordingHomeBloc() : super(HomeState()) {
    on<SearchEvent>((event, _) => queries.add(event.query));
  }

  final List<String> queries = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('Debouncer', () {
    testWidgets('runs only the last call, once calls stop for the delay', (
      tester,
    ) async {
      final runs = <int>[];
      final debouncer = Debouncer(const Duration(milliseconds: 400));
      for (var i = 1; i <= 5; i++) {
        debouncer(() => runs.add(i));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(runs, isEmpty, reason: 'still typing');
      await tester.pump(const Duration(milliseconds: 200));
      expect(runs, [5]);
    });

    testWidgets('flush runs now, cancel drops', (tester) async {
      final runs = <String>[];
      final debouncer = Debouncer(const Duration(milliseconds: 400));
      debouncer(() => runs.add('a'));
      debouncer.flush();
      expect(runs, ['a']);
      debouncer(() => runs.add('b'));
      debouncer.cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(runs, ['a']);
    });
  });

  group('search bar', () {
    late _RecordingHomeBloc bloc;
    late TextEditingController controller;

    Future<void> pumpBar(WidgetTester tester) async {
      bloc = _RecordingHomeBloc();
      controller = TextEditingController();
      addTearDown(bloc.close);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            home: Scaffold(
              body: BlocProvider<HomeBloc>.value(
                value: bloc,
                child: SearchWithFilterBar(controller: controller),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 150));
    }

    testWidgets('typing a word sends one search, after the pause', (
      tester,
    ) async {
      await pumpBar(tester);
      for (final text in ['برمج', 'برمجة', 'برمجة ', 'برمجة 1']) {
        await type(tester, text);
      }
      expect(bloc.queries, isEmpty, reason: 'no request per letter');
      await tester.pump(SearchWithFilterBar.searchDebounce);
      await tester.pump();
      expect(bloc.queries, ['برمجة 1']);
    });

    testWidgets('fewer than 4 letters: no search while typing', (tester) async {
      await pumpBar(tester);
      await type(tester, 'بر');
      await tester.pump(const Duration(seconds: 1));
      expect(bloc.queries, isEmpty);
    });

    testWidgets('the search key searches at once, short queries too', (
      tester,
    ) async {
      await pumpBar(tester);
      await type(tester, 'بر');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(bloc.queries, ['بر']);
    });

    testWidgets('clearing resets at once and drops a waiting search', (
      tester,
    ) async {
      await pumpBar(tester);
      await type(tester, 'فيزياء');
      await type(tester, '');
      await tester.pump(const Duration(seconds: 1));
      expect(bloc.queries, ['']);
    });

    testWidgets('the same query is not sent twice in a row', (tester) async {
      await pumpBar(tester);
      await type(tester, 'فيزياء');
      await tester.pump(SearchWithFilterBar.searchDebounce);
      await type(tester, 'فيزياء ');
      await type(tester, 'فيزياء');
      await tester.pump(SearchWithFilterBar.searchDebounce);
      await tester.pump();
      expect(bloc.queries, ['فيزياء']);
    });
  });
}
