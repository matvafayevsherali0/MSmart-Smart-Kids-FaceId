import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/navigation/router.dart';
import 'assets/theme/theme.dart';
import 'core/network/dio_setting.dart';
import 'features/auth/presentation/bloc/sign_in_bloc.dart';
import 'features/category_selection/main/presentation/bloc/category_selection_bloc.dart';
import 'features/devices/presentation/bloc/devices_bloc.dart';
import 'features/hikvision/presentation/bloc/hikvision_bloc.dart';
import 'features/organization/presentation/bloc/organization_bloc.dart';
import 'features/users/presentation/bloc/users_bloc.dart';

class MSmartKidsFaceId extends StatefulWidget {
  const MSmartKidsFaceId({super.key});

  @override
  State<MSmartKidsFaceId> createState() => _MSmartKidsFaceIdState();
}

class _MSmartKidsFaceIdState extends State<MSmartKidsFaceId> {
  StreamSubscription<String>? _unauthorizedSubscription;

  @override
  void initState() {
    super.initState();
    _unauthorizedSubscription = dioStreamController.stream.listen((event) {
      if (event == '401') {
        router.go(AppRoutes.signIn);
      }
    });
  }

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SignInBloc()),
        BlocProvider(create: (_) => OrganizationBloc()),
        BlocProvider(create: (_) => UsersBloc()),
        BlocProvider(create: (_) => HikvisionBloc()),
        BlocProvider(create: (_) => DevicesBloc()),
        BlocProvider(create: (_) => CategorySelectionBloc()),
      ],
      child: ScreenUtilInit(
        designSize: MediaQuery.of(context).size.width > 500 ? const Size(768, 1024) : const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeData(isDarkModeOn: MediaQuery.of(context).platformBrightness == Brightness.dark),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
