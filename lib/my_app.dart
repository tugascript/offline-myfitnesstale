import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/cubits/active_workout_cubit.dart';
import 'src/cubits/entitlement_cubit.dart';
import 'src/cubits/exercise_cubit.dart';
import 'src/cubits/exercise_record_cubit.dart';
import 'src/cubits/profile_cubit.dart';
import 'src/cubits/states/profile_state.dart';
import 'src/cubits/weight_record_cubit.dart';
import 'src/cubits/workout_cubit.dart';
import 'src/cubits/workout_plan_cubit.dart';
import 'src/cubits/workout_plan_record_cubit.dart';
import 'src/cubits/workout_record_cubit.dart';
import 'src/utilities/app_router.dart';
import 'src/utilities/theme_generator.dart';

class MyApp extends StatelessWidget {
  final RouterConfig<Object>? routerConfig;

  const MyApp({
    super.key,
    this.routerConfig,
  });

  @override
  Widget build(BuildContext context) {
    GoogleFonts.config.allowRuntimeFetching = false;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (BuildContext context) => ProfileCubit()..loadInitialData(),
          lazy: false,
        ),
        BlocProvider<EntitlementCubit>(
          create: (BuildContext context) => EntitlementCubit()..bootstrap(),
          lazy: false,
        ),
        BlocProvider<ExerciseCubit>(
          create: (BuildContext context) => ExerciseCubit(),
        ),
        BlocProvider<ExerciseRecordCubit>(
          create: (BuildContext context) => ExerciseRecordCubit(),
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
        BlocProvider<WorkoutPlanCubit>(
          create: (BuildContext context) => WorkoutPlanCubit(),
        ),
        BlocProvider<WorkoutPlanRecordCubit>(
          create: (BuildContext context) => WorkoutPlanRecordCubit(),
        ),
        BlocProvider<ActiveWorkoutCubit>(
          create: (BuildContext context) => ActiveWorkoutCubit(),
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          return previous.system?.theme != current.system?.theme;
        },
        builder: (context, state) {
          return MaterialApp.router(
            title: 'My Fitness Tale',
            theme: ThemeGenerator.themeFromContext(
              context,
              themeOverride: state.system?.theme,
            ),
            routerConfig: routerConfig ?? AppRouter.router,
          );
        },
      ),
    );
  }
}
