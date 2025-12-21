import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/muscle_cubit.dart';
import '../../cubits/muscle_group_cubit.dart';
import '../../cubits/states/muscle_group_state.dart';
import '../../cubits/states/muscle_state.dart';
import '../../models/enums.dart';
import '../../models/muscle_model.dart';

class MuscleSelectionWidget extends StatefulWidget {
  final List<(int, ExerciseMuscleCategory)> selectedMuscles;
  final Function(List<(int, ExerciseMuscleCategory)>) onSelectionChanged;

  const MuscleSelectionWidget({
    super.key,
    required this.selectedMuscles,
    required this.onSelectionChanged,
  });

  @override
  State<MuscleSelectionWidget> createState() => _MuscleSelectionWidgetState();
}

class _MuscleSelectionWidgetState extends State<MuscleSelectionWidget> {
  late List<(int, ExerciseMuscleCategory)> _selectedMuscles;

  @override
  void initState() {
    super.initState();
    _selectedMuscles = List.from(widget.selectedMuscles);
    _loadData();
  }

  void _loadData() {
    context.read<MuscleGroupCubit>().getMuscleGroups();
    context.read<MuscleCubit>().getMuscles();
  }

  void _toggleMuscle(int muscleId, ExerciseMuscleCategory category) {
    setState(() {
      final index = _selectedMuscles.indexWhere((m) => m.$1 == muscleId);
      if (index >= 0) {
        // If same category, remove; if different category, update
        if (_selectedMuscles[index].$2 == category) {
          _selectedMuscles.removeAt(index);
        } else {
          _selectedMuscles[index] = (muscleId, category);
        }
      } else {
        _selectedMuscles.add((muscleId, category));
      }
      widget.onSelectionChanged(_selectedMuscles);
    });
  }

  bool _isMuscleSelected(int muscleId, ExerciseMuscleCategory category) {
    return _selectedMuscles.any(
      (m) => m.$1 == muscleId && m.$2 == category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
      builder: (context, muscleGroupState) {
        return BlocBuilder<MuscleCubit, MuscleState>(
          builder: (context, muscleState) {
            if (muscleGroupState.isLoading || muscleState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final muscleGroups = muscleGroupState.muscleGroups;
            final muscles = muscleState.muscles;

            // Group muscles by muscle group
            final Map<int, List<Muscle>> groupedMuscles = {};
            for (final muscle in muscles) {
              groupedMuscles.putIfAbsent(muscle.muscleGroupId, () => []);
              groupedMuscles[muscle.muscleGroupId]!.add(muscle);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Muscles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...muscleGroups.map((group) {
                  final groupMuscles = groupedMuscles[group.id] ?? [];
                  if (groupMuscles.isEmpty) return const SizedBox.shrink();

                  return ExpansionTile(
                    title: Text(group.name),
                    children: groupMuscles.map((muscle) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(muscle.name),
                            ),
                            const SizedBox(width: 8),
                            _buildCategoryChip(
                              muscle.id!,
                              ExerciseMuscleCategory.primary,
                              'Primary',
                            ),
                            const SizedBox(width: 8),
                            _buildCategoryChip(
                              muscle.id!,
                              ExerciseMuscleCategory.secondary,
                              'Secondary',
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(
    int muscleId,
    ExerciseMuscleCategory category,
    String label,
  ) {
    final isSelected = _isMuscleSelected(muscleId, category);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _toggleMuscle(muscleId, category),
      selectedColor: category == ExerciseMuscleCategory.primary
          ? Colors.blue.withOpacity(0.3)
          : Colors.orange.withOpacity(0.3),
    );
  }
}

