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

import 'package:flutter/material.dart';

import '../../../../../data/repositories/workouts/dtos/workout_dto.dart';
import '../../../../../data/utils/display_names.dart';
import '../../../../../data/utils/enums.dart';
import '../../../../core/sizes/data_display_sizes.dart';
import '../../../../core/widgets/layout/app_dropdown.dart';
import '../workout_search/workout_plan_workout_search_modal.dart';
import '../workout_selection_button.dart';
import './workout_plan_editor_data.dart';

class WorkoutPlanWorkoutRowEditor extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final WorkoutPlanWorkoutEditorData workout;
  final ValueChanged<WorkoutPlanWorkoutEditorData> onChanged;

  const WorkoutPlanWorkoutRowEditor({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.workout,
    required this.onChanged,
  });

  @override
  State<WorkoutPlanWorkoutRowEditor> createState() =>
      _WorkoutPlanWorkoutRowEditorState();
}

class _WorkoutPlanWorkoutRowEditorState
    extends State<WorkoutPlanWorkoutRowEditor> {
  @override
  void initState() {
    super.initState();
    if (widget.workout.workoutName == null && !widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) {
          await _openWorkoutPicker(context);
        }
      });
    }
  }

  Future<void> _openWorkoutPicker(BuildContext context) async {
    final selected = await showDialog<WorkoutDto>(
      context: context,
      builder: (_) {
        return WorkoutPlanWorkoutSearchModal(
          sizes: widget.sizes,
          isLoading: widget.isLoading,
          onWorkoutSelected: (workoutDto) {
            Navigator.of(context).pop(workoutDto);
          },
        );
      },
    );

    if (selected == null) {
      return;
    }

    final updated = widget.workout.copy()
      ..workoutId = selected.id
      ..workoutName = selected.name;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.sizes.padding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkoutSelectionButton(
            onPressed: () {
              if (widget.isLoading) {
                return;
              }

              _openWorkoutPicker(context);
            },
            workoutName: widget.workout.workoutName,
            sizes: widget.sizes,
            theme: widget.theme,
          ),
          SizedBox(height: widget.sizes.spacing / 2),
          AppDropdown<WorkoutTimeOfDay>(
            filled: true,
            value: widget.workout.timeOfDay,
            emptyLabel: 'Anytime',
            labelText: 'Time Of Day',
            items: WorkoutTimeOfDay.values,
            fontSize: widget.sizes.smallFontSize,
            padding: widget.sizes.padding * 0.4,
            labelBuilder: EnumDisplayNames.getTimeOfDayDisplayName,
            onChanged: widget.isLoading
                ? (_) {}
                : (value) {
                    final updated = widget.workout.copy()..timeOfDay = value;
                    widget.onChanged(updated);
                  },
            onSaved: (_) {},
          ),
        ],
      ),
    );
  }
}
