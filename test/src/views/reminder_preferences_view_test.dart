import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:myfitnesstale/src/cubits/profile_cubit.dart';
import 'package:myfitnesstale/src/cubits/states/profile_state.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/profile_dto.dart';
import 'package:myfitnesstale/src/services/dtos/reminders_config_dto.dart';
import 'package:myfitnesstale/src/services/dtos/system_dto.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/views/profile/reminder_preferences_view.dart';
import 'package:myfitnesstale/src/widgets/dashboard/quick_actions_widget.dart';

class _ProfileCubit extends ProfileCubit {
  _ProfileCubit() {
    emit(ProfileState(
      profile: ProfileDto(
        id: 1,
        name: 'Tester',
        height: 175,
        gender: Gender.other,
        birthdate: DateTime(1990),
      ),
      system: const SystemDto(
        id: 1,
        units: Units.metric,
        theme: ThemeType.system,
        initialSetup: SetUpStatus.completed,
        notificationsOn: false,
      ),
      remindersConfig: const RemindersConfigDto(
        id: 1,
        workoutsOn: false,
        weightRecordsOn: false,
      ),
      isLoading: false,
      isInitiated: true,
    ));
  }

  bool? updatedWorkoutsOn;
  bool? updatedWeightRecordsOn;

  @override
  Future<void> updateRemindersConfig({
    bool? workoutsOn,
    bool? weightRecordsOn,
  }) async {
    updatedWorkoutsOn = workoutsOn;
    updatedWeightRecordsOn = weightRecordsOn;
    emit(state.copyWith(
      remindersConfig: state.remindersConfig!.copyWith(
        workoutsOn: workoutsOn,
        weightRecordsOn: weightRecordsOn,
      ),
    ));
  }
}

void main() {
  const sizes = DataDisplaySizesList(
    viewPadding: 10,
    subtitleFontSize: 14,
    titleFontSize: 20,
    fontSize: 12,
    smallFontSize: 10,
    buttonIconSize: 18,
    buttonSize: 40,
    margins: 16,
    padding: 12,
    spacing: 12,
    inputSpacing: 8,
    elevation: 1,
  );

  testWidgets('saved reminder toggles are expanded with delivery disclosure',
      (tester) async {
    final cubit = _ProfileCubit();
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: ReminderPreferencesView.routeName,
      routes: [
        GoRoute(
          path: ReminderPreferencesView.routeName,
          builder: (context, state) => const ReminderPreferencesView(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(
      find.textContaining('Notification delivery is not scheduled'),
      findsOneWidget,
    );
    expect(find.byType(Switch), findsNWidgets(2));

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(cubit.updatedWorkoutsOn, isTrue);
    expect(cubit.updatedWeightRecordsOn, isFalse);
  });

  testWidgets('dashboard Reminders opens reminder preferences', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(
              child: QuickActionsWidget(sizes: sizes),
            ),
          ),
        ),
        GoRoute(
          path: ReminderPreferencesView.routeName,
          builder: (context, state) =>
              const Scaffold(body: Text('Reminder preferences destination')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.ensureVisible(find.text('Reminders'));

    expect(find.text('Manage reminder preferences'), findsOneWidget);
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder preferences destination'), findsOneWidget);
  });
}
