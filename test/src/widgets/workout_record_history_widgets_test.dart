import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/common/nullable.dart';
import 'package:myfitnesstale/src/cubits/states/workout_record_state.dart';
import 'package:myfitnesstale/src/models/common.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/services/dtos/workout_dto.dart';
import 'package:myfitnesstale/src/services/dtos/workout_record_dto.dart';
import 'package:myfitnesstale/src/utilities/formatters.dart';
import 'package:myfitnesstale/src/utilities/sizes/data_display_sizes.dart';
import 'package:myfitnesstale/src/utilities/sizes/screen_size.dart';
import 'package:myfitnesstale/src/widgets/workouts/progress/history/single_workout_record_list.dart';
import 'package:myfitnesstale/src/widgets/workouts/progress/history/workout_record_head.dart';

void main() {
  WorkoutDto sampleWorkout(String name) => WorkoutDto(
    id: 1,
    name: name,
    muscleGroups: const {MuscleGroup.push},
    muscles: const TargetMuscles(
      primary: {Muscle.chest},
      secondary: {Muscle.triceps},
    ),
    difficulty: Difficulty.intermediate,
    version: 1,
    isFavorite: false,
    totalSets: 3,
    totalReps: 30,
    editorType: EditorType.basic,
    createdBy: CreatedBy.user,
  );

  WorkoutRecordDto sampleRecord({
    required DateTime startedAt,
    DateTime? completedAt,
    WorkoutDto? workout,
  }) => WorkoutRecordDto.empty().copyWith(
    id: 10,
    workoutId: 1,
    version: 1,
    startedAt: startedAt,
    completedAt: Nullable(completedAt),
    totalSets: 4,
    totalReps: 40,
    totalVolume: 2000000,
    totalRestSecs: 180,
    muscles: const TargetMuscles(
      primary: {Muscle.chest},
      secondary: {Muscle.triceps},
    ),
    workout: Nullable(workout),
  );

  group('Formatters.formatRelativeDate', () {
    final now = DateTime(2026, 11, 9, 15, 0);

    test(
      'returns Today, Yesterday, N days ago, and N weeks ago under 30 days',
      () {
        expect(
          Formatters.formatRelativeDate(
            Units.metric,
            DateTime(2026, 11, 9, 9, 0),
            now: now,
          ),
          'Today',
        );
        expect(
          Formatters.formatRelativeDate(
            Units.metric,
            DateTime(2026, 11, 8, 20, 0),
            now: now,
          ),
          'Yesterday',
        );
        expect(
          Formatters.formatRelativeDate(
            Units.metric,
            DateTime(2026, 11, 6, 12, 0),
            now: now,
          ),
          '3 days ago',
        );
        expect(
          Formatters.formatRelativeDate(
            Units.metric,
            DateTime(2026, 11, 2, 12, 0),
            now: now,
          ),
          '1 week ago',
        );
        expect(
          Formatters.formatRelativeDate(
            Units.metric,
            DateTime(2026, 10, 23, 12, 0),
            now: now,
          ),
          '2 weeks ago',
        );
      },
    );

    test('falls back to formatted date when 30 days or older', () {
      final older = DateTime(2026, 10, 1, 10, 0);
      expect(
        Formatters.formatRelativeDate(Units.metric, older, now: now),
        '01/10/2026',
      );
      expect(
        Formatters.formatRelativeDate(Units.imperial, older, now: now),
        '10/01/2026',
      );
    });
  });

  group('Formatters.formatDateTimeRange', () {
    final now = DateTime(2026, 11, 9, 15, 0);

    test('uses relative date when less than 1 month ago', () {
      final todayStart = DateTime(2026, 11, 9, 10, 30);
      final todayEnd = DateTime(2026, 11, 9, 11, 45);
      expect(
        Formatters.formatDateTimeRange(
          Units.metric,
          todayStart,
          todayEnd,
          now: now,
        ),
        'Today 10:30 - 11:45',
      );

      final yesterdayLate = DateTime(2026, 11, 8, 23, 30);
      final todayEarly = DateTime(2026, 11, 9, 0, 45);
      expect(
        Formatters.formatDateTimeRange(
          Units.metric,
          yesterdayLate,
          todayEarly,
          now: now,
        ),
        'Yesterday 23:30 - Today 00:45',
      );
    });

    test('formats start only when end is null (>1 month ago)', () {
      final start = DateTime(2026, 9, 9, 10, 30);
      expect(
        Formatters.formatDateTimeRange(Units.metric, start, null, now: now),
        '09/09/2026 10:30',
      );
      expect(
        Formatters.formatDateTimeRange(Units.imperial, start, null, now: now),
        '09/09/2026 10:30',
      );
    });

    test('shows date only once when start and end are on the same day (>1 month ago)', () {
      final start = DateTime(2026, 9, 15, 10, 30);
      final end = DateTime(2026, 9, 15, 11, 45);
      expect(
        Formatters.formatDateTimeRange(Units.metric, start, end, now: now),
        '15/09/2026 10:30 - 11:45',
      );
      expect(
        Formatters.formatDateTimeRange(Units.imperial, start, end, now: now),
        '09/15/2026 10:30 - 11:45',
      );
    });

    test('shows both dates when start and end are on different days (>1 month ago)', () {
      final start = DateTime(2026, 9, 15, 23, 30);
      final end = DateTime(2026, 9, 16, 0, 45);
      expect(
        Formatters.formatDateTimeRange(Units.metric, start, end, now: now),
        '15/09/2026 23:30 - 16/09/2026 00:45',
      );
      expect(
        Formatters.formatDateTimeRange(Units.imperial, start, end, now: now),
        '09/15/2026 23:30 - 09/16/2026 00:45',
      );
    });
  });

  testWidgets(
    'WorkoutRecordHead displays relative and older date-time ranges and workout name when provided',
    (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day, 10, 30);
      final todayEnd = DateTime(now.year, now.month, now.day, 11, 45);
      final sameDayRecord = sampleRecord(
        startedAt: todayStart,
        completedAt: todayEnd,
        workout: sampleWorkout('Push Day A'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(
                builder: (context) => WorkoutRecordHead(
                  sizes: sizes,
                  theme: Theme.of(context),
                  units: Units.metric,
                  isLoading: false,
                  workoutRecord: sameDayRecord,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text(' Push Day A'), findsOneWidget);
      expect(find.text(' Today 10:30 - 11:45'), findsOneWidget);
      expect(find.text(' 1h 15m 0s'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SingleWorkoutRecordList displays relative and older date-time ranges',
    (tester) async {
      final sizes = DataDisplaySizes.getDataDisplaySizes(ScreenSize.sm);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day, 10, 30);
      final todayEnd = DateTime(now.year, now.month, now.day, 11, 45);
      final records = [
        sampleRecord(
          startedAt: todayStart,
          completedAt: todayEnd,
          workout: sampleWorkout('Upper Body'),
        ),
        sampleRecord(
          startedAt: DateTime(2025, 5, 9, 23, 30),
          completedAt: DateTime(2025, 5, 10, 0, 45),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleWorkoutRecordList(
              sizes: sizes,
              units: Units.metric,
              isLoading: false,
              workoutRecords: records,
              pagination: const WorkoutRecordPagination(
                limit: 20,
                offset: 0,
                total: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text(' Upper Body'), findsOneWidget);
      expect(find.text(' Today 10:30 - 11:45'), findsOneWidget);
      expect(find.text(' 09/05/2025 23:30 - 10/05/2025 00:45'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
