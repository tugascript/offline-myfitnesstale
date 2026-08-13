import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/exercise_record_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/states/exercise_record_state.dart';
import '../cubits/states/profile_state.dart';
import '../models/enums.dart';
import '../services/dtos/exercise_dto.dart';
import '../services/dtos/exercise_record_dto.dart';
import '../utilities/converters.dart';
import '../utilities/formatters.dart';
import '../widgets/layout/app_scaffold.dart';
import 'exercises/exercise_records_view.dart';

class ExerciseProgressView extends StatefulWidget {
  static const routeName = '/exercises/progress';

  const ExerciseProgressView({super.key});

  @override
  State<ExerciseProgressView> createState() => _ExerciseProgressViewState();
}

class _ExerciseProgressViewState extends State<ExerciseProgressView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ExerciseRecordCubit>().getExerciseRecords(limit: 1000);
  }

  Map<int, List<ExerciseRecordDto>> _groupRecordsByExercise(
    List<ExerciseRecordDto> records,
  ) {
    final grouped = <int, List<ExerciseRecordDto>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.exerciseId, () => []).add(record);
    }
    return grouped;
  }

  ExerciseProgressData _calculateProgressData(
    List<ExerciseRecordDto> records,
  ) {
    if (records.isEmpty) {
      return const ExerciseProgressData.empty();
    }

    final personalBest = records.reduce((currentBest, candidate) {
      if (candidate.weight > currentBest.weight) {
        return candidate;
      }
      if (candidate.weight == currentBest.weight &&
          candidate.reps > currentBest.reps) {
        return candidate;
      }
      return currentBest;
    });

    return ExerciseProgressData(
      totalRecords: records.length,
      maxWeightGrams: records
          .map((record) => record.weight)
          .reduce((a, b) => a > b ? a : b),
      maxReps:
          records.map((record) => record.reps).reduce((a, b) => a > b ? a : b),
      personalBest: personalBest,
    );
  }

  List<ExerciseDto> _getFilteredExercises(
    Map<int, List<ExerciseRecordDto>> groupedRecords,
  ) {
    final exercises = <int, ExerciseDto>{};
    for (final records in groupedRecords.values) {
      if (records.isNotEmpty && records.first.exercise != null) {
        exercises[records.first.exerciseId] = records.first.exercise!;
      }
    }

    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final exerciseList = exercises.values
        .where(
          (exercise) =>
              normalizedQuery.isEmpty ||
              exercise.name.toLowerCase().contains(normalizedQuery),
        )
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

    return exerciseList;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Exercise Progress',
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final units = profileState.system?.units ?? Units.metric;

          return BlocBuilder<ExerciseRecordCubit, ExerciseRecordState>(
            builder: (context, state) {
              if (state.isLoading && state.exerciseRecords.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null && state.exerciseRecords.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading exercises',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ExerciseRecordCubit>()
                              .getExerciseRecords(limit: 1000),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final groupedRecords =
                  _groupRecordsByExercise(state.exerciseRecords);
              final filteredExercises = _getFilteredExercises(groupedRecords);

              if (filteredExercises.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Exercise Progress'
                              : 'No exercises found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Complete workouts with exercises to see progress here'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => context
                          .read<ExerciseRecordCubit>()
                          .getExerciseRecords(limit: 1000),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          final records = groupedRecords[exercise.id] ?? [];
                          final progress = _calculateProgressData(records);
                          final destination =
                              ExerciseRecordsView.location(exercise.id);

                          return Card(
                            key: ValueKey('exercise-progress-${exercise.id}'),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => context.push(destination),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'View exercise records',
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                          ),
                                          onPressed: () =>
                                              context.push(destination),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildProgressStat(
                                            'Records',
                                            '${progress.totalRecords}',
                                            Icons.event,
                                            Colors.blue,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildProgressStat(
                                            'Max Weight',
                                            _formatWeight(
                                              progress.maxWeightGrams,
                                              units,
                                            ),
                                            Icons.fitness_center,
                                            Colors.orange,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildProgressStat(
                                            'Max Reps',
                                            '${progress.maxReps}',
                                            Icons.repeat,
                                            Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.amber.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            color: Colors.amber[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Personal Best',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  '${_formatWeight(progress.personalBest!.weight, units)} × ${progress.personalBest!.reps} reps',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber[900],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatWeight(int grams, Units units) {
    final value = units == Units.metric
        ? Converters.gramsToKg(grams)
        : Converters.gramsToLbs(grams);
    final suffix = units == Units.metric ? 'kg' : 'lb';
    return '${Formatters.formatWeight(value)} $suffix';
  }

  Widget _buildProgressStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class ExerciseProgressData {
  final int totalRecords;
  final int maxWeightGrams;
  final int maxReps;
  final ExerciseRecordDto? personalBest;

  const ExerciseProgressData({
    required this.totalRecords,
    required this.maxWeightGrams,
    required this.maxReps,
    required this.personalBest,
  });

  const ExerciseProgressData.empty()
      : totalRecords = 0,
        maxWeightGrams = 0,
        maxReps = 0,
        personalBest = null;
}
