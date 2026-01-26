import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/profile_cubit.dart';
import '../cubits/states/profile_state.dart';
import '../cubits/states/weight_record_state.dart';
import '../cubits/weight_record_cubit.dart';
import '../models/enums.dart';
import '../models/weight_goal_model.dart';
import '../widgets/layout/responsive_scaffold.dart';
import '../widgets/weight/weight_input_widget.dart';

class WeightGoalView extends StatefulWidget {
  static const routeName = "/weight-goal";
  static const name = "weight-goal";

  final WeightGoal? goalToEdit;

  const WeightGoalView({super.key, this.goalToEdit});

  @override
  State<WeightGoalView> createState() => _WeightGoalViewState();
}

class _WeightGoalViewState extends State<WeightGoalView> {
  final _formKey = GlobalKey<FormState>();
  double _targetWeight = 0.0;
  DateTime _startDate = DateTime.now();
  ProgressStatus _selectedStatus = ProgressStatus.inProgress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _loadGoalData();
    }
  }

  void _loadGoalData() {
    final goal = widget.goalToEdit!;
    setState(() {
      _targetWeight = goal.targetWeight.toDouble();
      _startDate = DateTime.fromMillisecondsSinceEpoch(goal.startDate * 1000);
      _selectedStatus = goal.status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: widget.goalToEdit != null ? "Edit Goal" : "Set Weight Goal",
      showBackButton: true,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, profileState) {
          return BlocConsumer<WeightRecordCubit, WeightRecordState>(
            listener: (context, goalState) {
              if (goalState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${goalState.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (!goalState.isLoading && _isLoading) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.goalToEdit != null
                        ? 'Goal updated successfully!'
                        : 'Goal created successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            builder: (context, goalState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Goal Type Selection
                      _buildGoalTypeSection(),

                      const SizedBox(height: 24),

                      // Target Weight Input
                      WeightInputWidget(
                        initialWeight: _targetWeight > 0 ? _targetWeight : null,
                        units: profileState.system?.units ?? Units.metric,
                        onWeightChanged: (weight) {
                          setState(() {
                            _targetWeight = weight;
                          });
                        },
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Status Selection (for editing)
                      if (widget.goalToEdit != null) _buildStatusSection(),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitGoal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  widget.goalToEdit != null
                                      ? 'Update Goal'
                                      : 'Create Goal',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Delete Button (for editing)
                      if (widget.goalToEdit != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _deleteGoal,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Delete Goal',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGoalTypeCard(
                'Lose Weight',
                Icons.trending_down,
                Colors.red,
                'Reduce your current weight',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGoalTypeCard(
                'Gain Weight',
                Icons.trending_up,
                Colors.green,
                'Increase your current weight',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildGoalTypeCard(
          'Maintain Weight',
          Icons.trending_flat,
          Colors.blue,
          'Keep your current weight stable',
        ),
      ],
    );
  }

  Widget _buildGoalTypeCard(
      String title, IconData icon, Color color, String description) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Implement goal type selection logic
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProgressStatus>(
          initialValue: _selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
          ),
          items: ProgressStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(_getStatusDisplayName(status)),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
        ),
      ],
    );
  }

  void _submitGoal() {
    if (_formKey.currentState!.validate()) {
      if (_targetWeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid target weight'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final recordCubit = context.read<WeightRecordCubit>();
      if (widget.goalToEdit != null) {
        // Update existing goal
        recordCubit.updateWeightGoal(
          id: widget.goalToEdit!.id!,
          targetWeight: _targetWeight.round(),
          startDate: _startDate,
          status: _selectedStatus,
        );
      } else {
        // Create new goal
        recordCubit.createWeightGoal(
          targetWeight: _targetWeight.round(),
          startDate: _startDate,
          status: _selectedStatus,
        );
      }
    }
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: const Text(
            'Are you sure you want to delete this weight goal? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.goalToEdit?.id != null) {
                  context
                      .read<WeightRecordCubit>()
                      .deleteWeightGoal(widget.goalToEdit!.id!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusDisplayName(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.inProgress:
        return "In Progress";
      case ProgressStatus.completed:
        return "Completed";
      case ProgressStatus.abandoned:
        return "Abandoned";
    }
  }
}
