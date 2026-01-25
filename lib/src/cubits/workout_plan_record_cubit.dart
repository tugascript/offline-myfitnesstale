import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../services/workout_plan_record_service.dart';
import 'states/workout_plan_record_state.dart';

class WorkoutPlanRecordCubit extends Cubit<WorkoutPlanRecordState> {
  final WorkoutPlanRecordService _workoutPlanRecordService =
      WorkoutPlanRecordService();

  WorkoutPlanRecordCubit() : super(WorkoutPlanRecordState.initial());

  Logger _logger = Logger('WorkoutPlanRecordCubit');

  Future<void> getActivePlanRecord() async {}
}
