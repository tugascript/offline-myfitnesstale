import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/cubits/exercise_cubit.dart';
import 'src/cubits/profile_cubit.dart';
import 'src/cubits/weight_record_cubit.dart';
import 'src/cubits/workout_cubit.dart';
import 'src/cubits/workout_plan_record_cubit.dart';
import 'src/cubits/workout_record_cubit.dart';
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
        BlocProvider<ExerciseCubit>(
          create: (BuildContext context) => ExerciseCubit(),
        ),
        BlocProvider<WeightRecordCubit>(
          create: (BuildContext context) => WeightRecordCubit(),
        ),
        BlocProvider<WorkoutCubit>(
          create: (BuildContext context) => WorkoutCubit(),
        ),
        BlocProvider<WorkoutRecordCubit>(
          create: (BuildContext context) => WorkoutRecordCubit(),
        ),
        BlocProvider<WorkoutPlanRecordCubit>(
          create: (BuildContext context) => WorkoutPlanRecordCubit(),
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
