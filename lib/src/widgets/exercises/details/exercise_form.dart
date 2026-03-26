import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/exercise_cubit.dart';
import '../../../cubits/states/exercise_state.dart';
import '../../../models/enums.dart';
import '../../../models/utilities.dart';
import '../../../utilities/sizes/data_display_sizes.dart';
import '../../layout/app_dropdown.dart';
import '../../layout/app_elevated_button.dart';
import '../../layout/app_text_form_field.dart';
import '../../layout/dynamic_list_input.dart';

class ExerciseForm extends StatefulWidget {
  final ThemeData theme;
  final DataDisplaySizesList sizes;
  final bool isLoading;
  final String submitLabel;

  final String initialName;
  final String? initialDescription;
  final MuscleGroup? initialMuscleGroup;
  final Set<Muscle> initialPrimaryMuscles;
  final Set<Muscle> initialSecondaryMuscles;
  final Set<int> initialEquipmentIds;
  final Difficulty? initialDifficulty;
  final bool initialIsFavorite;

  final void Function({
    required String name,
    required String? description,
    required MuscleGroup muscleGroup,
    required Set<Muscle> primaryMuscles,
    required Set<Muscle> secondaryMuscles,
    required Set<int> equipmentIds,
    required Difficulty? difficulty,
    required bool isFavorite,
  }) onSubmit;

  const ExerciseForm({
    super.key,
    required this.theme,
    required this.sizes,
    required this.isLoading,
    required this.submitLabel,
    required this.initialName,
    required this.initialDescription,
    required this.initialMuscleGroup,
    required this.initialPrimaryMuscles,
    required this.initialSecondaryMuscles,
    required this.initialEquipmentIds,
    required this.initialDifficulty,
    required this.initialIsFavorite,
    required this.onSubmit,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final _FormData _data;

  @override
  void initState() {
    super.initState();
    context.read<ExerciseCubit>().getSelectionEquipments();
    _data = _FormData(
      name: widget.initialName,
      description: widget.initialDescription ?? '',
      muscleGroup: widget.initialMuscleGroup,
      primaryMuscles: widget.initialPrimaryMuscles,
      secondaryMuscles: widget.initialSecondaryMuscles,
      equipmentIds: widget.initialEquipmentIds,
      difficulty: widget.initialDifficulty,
      isFavorite: widget.initialIsFavorite,
    );
    _nameController.text = _data.name;
    _descriptionController.text = _data.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: AppTextFormField(
                  filled: true,
                  theme: widget.theme,
                  maxLines: 1,
                  isLoading: widget.isLoading,
                  controller: _nameController,
                  labelText: "Name",
                  hintText: "Enter exercise name",
                  fontSize: widget.sizes.subtitleFontSize,
                  padding: widget.sizes.padding,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _data.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.theme.colorScheme.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _data.isFavorite = !_data.isFavorite;
                  });
                },
                tooltip: _data.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          AppTextFormField(
            filled: true,
            theme: widget.theme,
            isLoading: widget.isLoading,
            controller: _descriptionController,
            labelText: "Description",
            hintText: "Enter exercise description",
            maxLines: 4,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            onChanged: (value) {
              setState(() {
                _data.description = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.description = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<MuscleGroup>(
            value: _data.muscleGroup,
            filled: true,
            emptyLabel: 'Muscle Group',
            items: MuscleGroup.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: (d) => EnumDisplayNames.getMuscleGroupDisplayName(d),
            onChanged: (value) {
              setState(() {
                _data.muscleGroup = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.muscleGroup = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppDropdown<Difficulty>(
            value: _data.difficulty,
            filled: true,
            emptyLabel: 'Difficulty',
            items: Difficulty.values,
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            labelBuilder: (d) => EnumDisplayNames.getDifficultyDisplayName(d),
            onChanged: (value) {
              setState(() {
                _data.difficulty = value;
              });
            },
            onSaved: (value) {
              if (value != null) {
                setState(() {
                  _data.difficulty = value;
                });
              }
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          Text(
            "🥇 Primary Muscles",
            style: TextStyle(
              fontSize: widget.sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.sizes.spacing),
          DynamicListInput<Muscle>(
            filled: true,
            theme: widget.theme,
            handlesPadding: widget.sizes.padding,
            items: _data.primaryMuscles.toList(),
            itemBuilder: (context, index, item) {
              return AppDropdown<Muscle>(
                filled: true,
                value: item,
                emptyLabel: 'Primary Muscle',
                items: Muscle.values
                    .where(
                      (m) => !_data.secondaryMuscles.contains(m),
                    )
                    .toList(),
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                labelBuilder: (d) => EnumDisplayNames.getMuscleDisplayName(d),
                onChanged: (value) {
                  setState(() {
                    _data.primaryMuscles.remove(item);
                    if (value != null) {
                      _data.primaryMuscles.add(value);
                    }
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.primaryMuscles.add(value);
                    });
                  }
                },
              );
            },
            onChanged: (value) {
              setState(() {
                _data.primaryMuscles = value.toSet();
              });
            },
            onAdd: () {
              if (_data.primaryMuscles.length >= Muscle.values.length) {
                return;
              }
              for (final m in Muscle.values) {
                if (!(_data.primaryMuscles.contains(m) ||
                    _data.secondaryMuscles.contains(m))) {
                  setState(() {
                    _data.primaryMuscles.add(m);
                  });
                  break;
                }
              }
            },
            keyBuilder: (item) => ValueKey(item),
            addLabel: 'Add Muscle',
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            spacing: widget.sizes.spacing,
            isLoading: widget.isLoading,
          ),
          SizedBox(height: widget.sizes.spacing),
          Text(
            "🥈 Secondary Muscles",
            style: TextStyle(
              fontSize: widget.sizes.subtitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: widget.sizes.spacing),
          DynamicListInput<Muscle>(
            theme: widget.theme,
            handlesPadding: widget.sizes.padding / 3,
            items: _data.secondaryMuscles.toList(),
            filled: true,
            itemBuilder: (context, index, item) {
              return AppDropdown<Muscle>(
                value: item,
                filled: true,
                emptyLabel: 'Secondary Muscle',
                items: Muscle.values
                    .where(
                      (m) => !_data.primaryMuscles.contains(m),
                    )
                    .toList(),
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                labelBuilder: (d) => EnumDisplayNames.getMuscleDisplayName(d),
                onChanged: (value) {
                  setState(() {
                    _data.secondaryMuscles.remove(item);
                    if (value != null) {
                      _data.secondaryMuscles.add(value);
                    }
                  });
                },
                onSaved: (value) {
                  if (value != null) {
                    setState(() {
                      _data.secondaryMuscles.add(value);
                    });
                  }
                },
              );
            },
            onChanged: (value) {
              setState(() {
                _data.secondaryMuscles = value.toSet();
              });
            },
            onAdd: () {
              if (_data.secondaryMuscles.length >= Muscle.values.length) {
                return;
              }

              for (final m in Muscle.values) {
                if (!(_data.secondaryMuscles.contains(m) ||
                    _data.primaryMuscles.contains(m))) {
                  setState(() {
                    _data.secondaryMuscles.add(m);
                  });
                  break;
                }
              }
            },
            keyBuilder: (item) => ValueKey(item),
            addLabel: 'Add Muscle',
            fontSize: widget.sizes.subtitleFontSize,
            padding: widget.sizes.padding,
            spacing: widget.sizes.spacing,
            isLoading: widget.isLoading,
          ),
          SizedBox(height: widget.sizes.spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.fitness_center,
                size: widget.sizes.subtitleFontSize,
              ),
              Text(
                " Equipments",
                style: TextStyle(
                  fontSize: widget.sizes.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sizes.spacing),
          BlocBuilder<ExerciseCubit, ExerciseState>(
            builder: (context, state) {
              final equipmentIds = state.equipmentSelection.keys.toList();
              if (equipmentIds.isEmpty) {
                return const SizedBox.shrink();
              }

              return DynamicListInput<int>(
                theme: widget.theme,
                handlesPadding: widget.sizes.padding,
                items: _data.equipmentIds.toList(),
                filled: true,
                itemBuilder: (context, index, item) {
                  return AppDropdown<int>(
                    value: item,
                    filled: true,
                    emptyLabel: 'Equipment',
                    items: equipmentIds,
                    fontSize: widget.sizes.subtitleFontSize,
                    padding: widget.sizes.padding,
                    labelBuilder: (d) => state.equipmentSelection[d]!,
                    onChanged: (value) {
                      setState(() {
                        _data.equipmentIds.remove(item);
                        if (value != null) {
                          _data.equipmentIds.add(value);
                        }
                      });
                    },
                    onSaved: (value) {
                      if (value != null) {
                        setState(() {
                          _data.equipmentIds.add(value);
                        });
                      }
                    },
                  );
                },
                onChanged: (value) {
                  setState(() {
                    _data.equipmentIds = value.toSet();
                  });
                },
                onAdd: () {
                  if (equipmentIds.isEmpty ||
                      _data.equipmentIds.length >= equipmentIds.length) {
                    return;
                  }

                  for (final id in equipmentIds) {
                    if (!_data.equipmentIds.contains(id)) {
                      setState(() {
                        _data.equipmentIds.add(id);
                      });
                      break;
                    }
                  }
                },
                keyBuilder: (item) => ValueKey(item),
                addLabel: 'Add Equipment',
                fontSize: widget.sizes.subtitleFontSize,
                padding: widget.sizes.padding,
                spacing: widget.sizes.spacing,
                isLoading: state.isLoading,
              );
            },
          ),
          SizedBox(height: widget.sizes.spacing),
          AppElevatedButton(
            theme: widget.theme,
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  _data.muscleGroup != null) {
                widget.onSubmit(
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  muscleGroup: _data.muscleGroup!,
                  primaryMuscles: _data.primaryMuscles,
                  secondaryMuscles: _data.secondaryMuscles,
                  equipmentIds: _data.equipmentIds,
                  difficulty: _data.difficulty,
                  isFavorite: _data.isFavorite,
                );
              }
            },
            isLoading: widget.isLoading,
            sizes: widget.sizes,
            label: widget.submitLabel,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
}

final class _FormData {
  String name;
  String description;
  MuscleGroup? muscleGroup;
  Set<Muscle> primaryMuscles;
  Set<Muscle> secondaryMuscles;
  Set<int> equipmentIds;
  Difficulty? difficulty;
  bool isFavorite;

  _FormData({
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipmentIds,
    required this.difficulty,
    required this.isFavorite,
  });
}
