// Copyright (C) 2026 afonsobarracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfitnesstale/src/data/utils/enums.dart';
import 'package:myfitnesstale/src/ui/core/widgets/base_common_search_form.dart';
import 'package:myfitnesstale/src/ui/core/widgets/confirmation_dialog.dart';

void main() {
  const phoneSize = Size(320, 568);

  testWidgets('equipment search form fits narrow screens with large text', (
    tester,
  ) async {
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
                  onSubmit:
                      ({
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

  testWidgets('confirmation dialog scrolls long content on a narrow phone', (
    tester,
  ) async {
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
