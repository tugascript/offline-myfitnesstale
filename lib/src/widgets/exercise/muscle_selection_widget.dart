import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/muscle_group_cubit.dart';
import '../../cubits/states/muscle_group_state.dart';
import '../../models/enums.dart';
import '../../models/utilities.dart';

class MuscleSelectionWidget extends StatefulWidget {
  final List<(Muscle, ExerciseMuscleCategory)> selectedMuscles;
  final Function(List<(Muscle, ExerciseMuscleCategory)>) onSelectionChanged;

  const MuscleSelectionWidget({
    super.key,
    required this.selectedMuscles,
    required this.onSelectionChanged,
  });

  @override
  State<MuscleSelectionWidget> createState() => _MuscleSelectionWidgetState();
}

class _MuscleSelectionWidgetState extends State<MuscleSelectionWidget> {
  late List<(Muscle, ExerciseMuscleCategory)> _selectedMuscles;

  @override
  void initState() {
    super.initState();
    _selectedMuscles = List.from(widget.selectedMuscles);
    _loadData();
  }

  void _loadData() {
    context.read<MuscleGroupCubit>().getMuscleGroups();
  }

  String _formatMuscleGroupName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.full:
        return 'Full Body';
      case MuscleGroup.push:
        return 'Push';
      case MuscleGroup.pull:
        return 'Pull';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.core:
        return 'Core';
    }
  }

  void _toggleMuscle(Muscle muscle, ExerciseMuscleCategory category) {
    setState(() {
      final index = _selectedMuscles.indexWhere((m) => m.$1 == muscle);
      if (index >= 0) {
        // If same category, remove; if different category, update
        if (_selectedMuscles[index].$2 == category) {
          _selectedMuscles.removeAt(index);
        } else {
          _selectedMuscles[index] = (muscle, category);
        }
      } else {
        _selectedMuscles.add((muscle, category));
      }
      widget.onSelectionChanged(_selectedMuscles);
    });
  }

  bool _isMuscleSelected(Muscle muscle, ExerciseMuscleCategory category) {
    return _selectedMuscles.any(
      (m) => m.$1 == muscle && m.$2 == category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
      builder: (context, muscleGroupState) {
        if (muscleGroupState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final muscleGroups = muscleGroupState.muscleGroups;

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
              final groupMuscles = kMuscleGroupMuscleMap[group] ?? <Muscle>{};
              if (groupMuscles.isEmpty) return const SizedBox.shrink();

              return ExpansionTile(
                title: Text(_formatMuscleGroupName(group)),
                children: groupMuscles.map((muscle) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              EnumDisplayNames.getMuscleDisplayName(muscle)),
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          muscle,
                          ExerciseMuscleCategory.primary,
                          'Primary',
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                          muscle,
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
  }

  Widget _buildCategoryChip(
    Muscle muscle,
    ExerciseMuscleCategory category,
    String label,
  ) {
    final isSelected = _isMuscleSelected(muscle, category);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _toggleMuscle(muscle, category),
      selectedColor: category == ExerciseMuscleCategory.primary
          ? Colors.blue.withValues(alpha: 0.3)
          : Colors.orange.withValues(alpha: 0.3),
    );
  }
}
