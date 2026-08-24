import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfitnesstale/src/models/enums.dart';
import 'package:myfitnesstale/src/widgets/common/base_common_search_form.dart';
import 'package:myfitnesstale/src/widgets/common/confirmation_dialog.dart';

void main() {
  const phoneSize = Size(320, 568);

  testWidgets('equipment search form fits narrow screens with large text',
      (tester) async {
    await tester.binding.setSurfaceSize(phoneSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    int? submittedEquipmentId;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: phoneSize,
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Builder(
                builder: (context) => BaseCommonSearchForm(
                  theme: Theme.of(context),
                  nameLabel: 'Exercise',
                  fontSize: 14,
                  padding: 12,
                  spacing: 8,
                  isLoading: false,
                  initialName: '',
                  initialDifficulty: null,
                  initialMuscleGroup: null,
                  initialEquipmentId: null,
                  equipmentSelection: const {1: 'Barbell'},
                  initialIsFavorite: false,
                  onSubmit: ({
                    required String name,
                    required Difficulty? difficulty,
                    required MuscleGroup? muscleGroup,
                    required int? equipmentId,
                    required bool isFavourite,
                  }) {
                    submittedEquipmentId = equipmentId;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('All Equipment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search).last);
    await tester.pump();
    expect(submittedEquipmentId, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation dialog scrolls long content on a narrow phone',
      (tester) async {
    await tester.binding.setSurfaceSize(phoneSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: phoneSize,
            textScaler: TextScaler.linear(2),
          ),
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: 'Delete this very important item',
                    content: List.filled(
                      12,
                      'This action has a detailed consequence.',
                    ).join(' '),
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmationDialog), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
