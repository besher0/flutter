import 'package:coursaty_student_and_teacher/core/di/di_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// After sign-out the GetIt graph is recreated. Widgets that read a bloc from
/// `context` must then get the same new instance as code using `GetIt`,
/// otherwise a download runs on one bloc while the screen watches another.
class _CounterCubit extends Cubit<int> {
  _CounterCubit(super.initial);
}

void main() {
  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('context follows GetIt after a dependency reset', (tester) async {
    GetIt.I.registerSingleton<_CounterCubit>(_CounterCubit(1));
    late BuildContext innerContext;

    await tester.pumpWidget(
      ValueListenableBuilder<int>(
        valueListenable: dependenciesGeneration,
        builder: (context, _, child) => BlocProvider.value(
          value: GetIt.I<_CounterCubit>(),
          child: child!,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              innerContext = context;
              return BlocBuilder<_CounterCubit, int>(
                builder: (context, value) => Text('value $value'),
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('value 1'), findsOneWidget);

    final old = GetIt.I<_CounterCubit>();

    // What resetDependencies() does, with a stand-in registration.
    await GetIt.I.reset();
    GetIt.I.registerSingleton<_CounterCubit>(_CounterCubit(2));
    dependenciesGeneration.value++;
    await tester.pump();

    expect(find.text('value 2'), findsOneWidget);
    expect(
      identical(BlocProvider.of<_CounterCubit>(innerContext), GetIt.I<_CounterCubit>()),
      isTrue,
    );

    // The screen now listens to the new instance only.
    old.emit(9);
    await tester.pumpAndSettle();
    expect(find.text('value 2'), findsOneWidget);

    GetIt.I<_CounterCubit>().emit(3);
    await tester.pumpAndSettle();
    expect(find.text('value 3'), findsOneWidget);
  });
}
