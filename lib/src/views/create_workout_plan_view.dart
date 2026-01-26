import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/workout_plan_cubit.dart';
import '../models/enums.dart';
import '../widgets/layout/responsive_scaffold.dart';

class CreateWorkoutPlanView extends StatefulWidget {
  final int? workoutPlanId; // If provided, we're editing

  const CreateWorkoutPlanView({
    super.key,
    this.workoutPlanId,
  });

  @override
  State<CreateWorkoutPlanView> createState() => _CreateWorkoutPlanViewState();
}

class _CreateWorkoutPlanViewState extends State<CreateWorkoutPlanView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalWeeksController = TextEditingController(text: '4');
  Difficulty _selectedDifficulty = Difficulty.beginner;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutPlanId != null) {
      _loadPlanForEditing();
    }
  }

  Future<void> _loadPlanForEditing() async {
    final cubit = context.read<WorkoutPlanCubit>();
    await cubit.getWorkoutPlan(widget.workoutPlanId!);
    if (mounted) {
      final plan = cubit.state.selectedWorkoutPlan;
      if (plan != null) {
        _nameController.text = plan.name;
        _descriptionController.text = plan.description ?? '';
        _totalWeeksController.text = plan.totalWeeks.toString();
        _selectedDifficulty = Difficulty.fromValue(plan.difficulty);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _totalWeeksController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final cubit = context.read<WorkoutPlanCubit>();
      final totalWeeks = int.parse(_totalWeeksController.text);

      if (widget.workoutPlanId != null) {
        await cubit.updateWorkoutPlan(
          id: widget.workoutPlanId!,
          name: _nameController.text.trim(),
          difficulty: _selectedDifficulty,
          totalWeeks: totalWeeks,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      } else {
        await cubit.createWorkoutPlan(
          name: _nameController.text.trim(),
          difficulty: _selectedDifficulty,
          totalWeeks: totalWeeks,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.workoutPlanId != null
                ? 'Plan updated successfully'
                : 'Plan created successfully'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.beginnerIntermediate:
        return 'Beginner / Intermediate';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.intermediateAdvanced:
        return 'Intermediate / Advanced';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: widget.workoutPlanId != null ? 'Edit Plan' : 'Create Plan',
      body: BlocProvider.value(
        value: context.read<WorkoutPlanCubit>(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a plan name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Difficulty>(
                      initialValue: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty *',
                        border: OutlineInputBorder(),
                      ),
                      items: Difficulty.values
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(_difficultyLabel(d)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _totalWeeksController,
                      decoration: const InputDecoration(
                        labelText: 'Total Weeks *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final weeks = int.tryParse(value);
                        if (weeks == null || weeks < 1) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePlan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.workoutPlanId != null
                          ? 'Update Plan'
                          : 'Create Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
