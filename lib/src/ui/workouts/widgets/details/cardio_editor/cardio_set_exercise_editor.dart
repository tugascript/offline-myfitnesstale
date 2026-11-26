// Copyright (C) 2026 Afonso Barracha
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

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../data/repositories/exercises/dtos/exercise_dto.dart';
import '../../../../../data/utils/display_names.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_dropdown.dart';
import '../../../../core/widgets/layout/app_text_form_field.dart';
import '../editors/exercise_selection_button.dart';
import './cardio_duration_input.dart';
import './cardio_exercise_search_modal.dart';
import './cardio_set_editor_data.dart';

class CardioSetExerciseEditor extends StatefulWidget {
  final CardioSetExerciseEditorData exerciseData;
  final CardioSetType setType;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final ValueChanged<ExerciseDto>? onExerciseChanged;
  final ValueChanged<CardioBaseMode>? onModeChanged;
  final ValueChanged<int>? onQuantityChanged;
  final ValueChanged<int>? onRestSecsChanged;

  const CardioSetExerciseEditor({
    super.key,
    required this.exerciseData,
    required this.setType,
    required this.sizes,
    required this.isLoading,
    this.onExerciseChanged,
    this.onModeChanged,
    this.onQuantityChanged,
    this.onRestSecsChanged,
  });

  @override
  State<CardioSetExerciseEditor> createState() =>
      _CardioSetExerciseEditorState();
}

class _CardioSetExerciseEditorState extends State<CardioSetExerciseEditor> {
  late final TextEditingController _unitsController;

  @override
  void initState() {
    super.initState();
    _unitsController = TextEditingController(
      text: widget.exerciseData.quantity > 0
          ? widget.exerciseData.quantity.toString()
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant CardioSetExerciseEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentParsed = int.tryParse(_unitsController.text) ?? 0;
    if (oldWidget.exerciseData.mode != widget.exerciseData.mode ||
        currentParsed != widget.exerciseData.quantity) {
      final nextText = widget.exerciseData.quantity > 0
          ? widget.exerciseData.quantity.toString()
          : '';
      if (_unitsController.text != nextText) {
        _unitsController.text = nextText;
      }
    }
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizes = widget.sizes;
    final exerciseData = widget.exerciseData;
    final unitLabel =
        exerciseData.exerciseUnit != null &&
            exerciseData.exerciseUnit!.trim().isNotEmpty
        ? exerciseData.exerciseUnit!.trim()
        : 'Units';

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExerciseSelectionButton(
              icon: Icons.directions_run,
              exerciseName: exerciseData.exerciseName,
              sizes: sizes,
              theme: theme,
              onPressed: () {
                if (widget.isLoading || widget.onExerciseChanged == null) {
                  return;
                }
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return CardioExerciseSearchModal(
                      sizes: sizes,
                      isLoading: widget.isLoading,
                      onExerciseSelected: (exercise) {
                        widget.onExerciseChanged!(exercise);
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: sizes.spacing / 2),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppDropdown<CardioBaseMode>(
                    theme: theme,
                    isLoading: widget.isLoading,
                    value: exerciseData.mode,
                    emptyLabel: 'Mode',
                    labelText: 'Mode',
                    showEmptyValue: false,
                    items: CardioBaseMode.values,
                    labelBuilder: EnumDisplayNames.getCardioBaseModeDisplayName,
                    onChanged: (value) {
                      if (value == null || widget.isLoading) return;
                      widget.onModeChanged?.call(value);
                    },
                    onSaved: (value) {
                      if (value == null || widget.isLoading) return;
                      widget.onModeChanged?.call(value);
                    },
                    fontSize: sizes.fontSize,
                    padding: sizes.padding * 0.4,
                    filled: true,
                  ),
                ),
                SizedBox(width: sizes.spacing / 2),
                Expanded(
                  flex: 3,
                  child: exerciseData.mode == CardioBaseMode.time
                      ? CardioDurationInput(
                          theme: theme,
                          sizes: sizes,
                          seconds: exerciseData.quantity,
                          labelText: 'Duration',
                          sheetTitle: 'Duration',
                          allowHours: true,
                          minSeconds: 1,
                          enabled: !widget.isLoading,
                          icon: Icons.schedule,
                          onChanged: widget.onQuantityChanged,
                        )
                      : AppTextFormField(
                          controller: _unitsController,
                          theme: theme,
                          isLoading: widget.isLoading,
                          labelText: unitLabel,
                          hintText: 'Enter $unitLabel',
                          fontSize: sizes.fontSize,
                          padding: sizes.padding,
                          filled: true,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: Icon(
                            Icons.straighten,
                            size: sizes.fontSize * 1.2,
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 0;
                            widget.onQuantityChanged?.call(parsed);
                          },
                        ),
                ),
              ],
            ),
            if (widget.setType == CardioSetType.interval) ...[
              SizedBox(height: sizes.spacing / 2),
              CardioDurationInput(
                theme: theme,
                sizes: sizes,
                seconds: exerciseData.restSecs,
                labelText: 'Exercise Rest',
                sheetTitle: 'Exercise Rest',
                allowHours: false,
                minSeconds: 0,
                enabled: !widget.isLoading,
                icon: Icons.timer,
                onChanged: widget.onRestSecsChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
