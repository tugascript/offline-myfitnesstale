import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/muscle_group_cubit.dart';
import '../../cubits/states/muscle_group_state.dart';
import '../../models/enums.dart';
import '../../utilities/sizes/exercises_list_sizes.dart';

class ExercisesSearch extends StatefulWidget {
  final ExercisesListSizesList sizes;
  final bool isLoading;
  final String initialName;
  final MuscleGroup? initialMuscleGroup;

  const ExercisesSearch({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.initialName,
    required this.initialMuscleGroup,
  });

  @override
  State<ExercisesSearch> createState() => _ExercisesSearchState();
}

class _ExercisesSearchState extends State<ExercisesSearch> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    _data = _FormData(
      name: widget.initialName,
      muscleGroup: widget.initialMuscleGroup,
    );
    _nameController.text = _data.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            onChanged: (value) {
              setState(() {
                _data.name = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.name = value;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _data.name.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _data.name = '';
                        });
                        _nameController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.sizes.radius),
              ),
            ),
          ),
          SizedBox(height: widget.sizes.inputSpacing),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<MuscleGroupCubit, MuscleGroupState>(
                    builder: (context, state) {
                  final muscleGroups = state.muscleGroups;
                  return DropdownButtonFormField<MuscleGroup?>(
                    initialValue: _data.muscleGroup,
                    items: [
                      const DropdownMenuItem<MuscleGroup?>(
                        value: null,
                        child: Text('All muscle group'),
                      ),
                      ...muscleGroups.map(
                        (group) => DropdownMenuItem<MuscleGroup?>(
                          value: group,
                          child: Text(_formatMuscleGroupName(group)),
                        ),
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _data.muscleGroup = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _data.muscleGroup = value;
                      });
                    },
                  );
                }),
              )
            ],
          )
        ],
      ),
    );
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
}

final class _FormData {
  String name;
  MuscleGroup? muscleGroup;

  _FormData({
    required this.name,
    required this.muscleGroup,
  });
}
