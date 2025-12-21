import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfitnesstale/src/cubits/workout_cubit.dart';
import 'package:myfitnesstale/src/cubits/workout_record_cubit.dart';

import 'src/cubits/current_workout_plan_record_cubit.dart';
import 'src/cubits/equipment_cubit.dart';
import 'src/cubits/exercise_cubit.dart';
import 'src/cubits/muscle_cubit.dart';
import 'src/cubits/muscle_group_cubit.dart';
import 'src/cubits/profile_cubit.dart';
import 'src/cubits/weight_goal_cubit.dart';
import 'src/cubits/weight_record_cubit.dart';
import 'src/utilities/app_router.dart';
import 'src/utilities/theme_generator.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (BuildContext context) => ProfileCubit(),
        ),
        BlocProvider<WeightRecordCubit>(
          create: (BuildContext context) => WeightRecordCubit(),
        ),
        BlocProvider<WeightGoalCubit>(
          create: (BuildContext context) => WeightGoalCubit(),
        ),
        BlocProvider<ExerciseCubit>(
          create: (BuildContext context) => ExerciseCubit(),
        ),
        BlocProvider<MuscleCubit>(
          create: (BuildContext context) => MuscleCubit(),
        ),
        BlocProvider<MuscleGroupCubit>(
          create: (BuildContext context) => MuscleGroupCubit(),
        ),
        BlocProvider<WorkoutCubit>(
          create: (BuildContext context) => WorkoutCubit(),
        ),
        BlocProvider<WorkoutRecordCubit>(
          create: (BuildContext context) => WorkoutRecordCubit(),
        ),
        BlocProvider<EquipmentCubit>(
          create: (BuildContext context) => EquipmentCubit(),
        ),
        BlocProvider<CurrentWorkoutPlanRecordCubit>(
          create: (BuildContext context) => CurrentWorkoutPlanRecordCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: 'My Fitness Tale',
        theme: ThemeGenerator.themeFromContext(context),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
