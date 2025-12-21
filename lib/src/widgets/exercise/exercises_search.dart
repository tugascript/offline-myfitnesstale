import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/muscle_group_cubit.dart';
import '../../cubits/states/muscle_group_state.dart';
import '../../utilities/sizes/exercises_list_sizes.dart';

class ExercisesSearch extends StatefulWidget {
  final ExercisesListSizesList sizes;
  final bool isLoading;
  final String initialName;
  final int? initialMuscleGroupId;

  const ExercisesSearch({
    super.key,
    required this.sizes,
    required this.isLoading,
    required this.initialName,
    required this.initialMuscleGroupId,
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
      muscleGroupId: widget.initialMuscleGroupId,
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
                  return DropdownButtonFormField<int?>(
                    initialValue: _data.muscleGroupId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All muscle group'),
                      ),
                      ...state.muscleGroups.map(
                        (mg) => DropdownMenuItem<int?>(
                          value: mg.id,
                          child: Text(mg.name),
                        ),
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _data.muscleGroupId = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _data.muscleGroupId = value;
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
}

final class _FormData {
  String name;
  int? muscleGroupId;

  _FormData({
    required this.name,
    required this.muscleGroupId,
  });
}
