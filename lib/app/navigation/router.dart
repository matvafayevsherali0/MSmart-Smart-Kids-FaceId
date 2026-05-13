import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/page/account_screen.dart';
import '../../features/auth/presentation/pages/launch_gate_screen.dart';
import '../../features/auth/presentation/pages/pin_screen.dart';
import '../../features/auth/presentation/pages/sign_in_screen.dart';
import '../../features/category_selection/employees/presentation/page/employees_screen.dart';
import '../../features/category_selection/main/presentation/page/category_selection_screen.dart';
import '../../features/category_selection/pupils/presentation/page/pupils_screen.dart';
import '../../features/category_selection/pupils_classes/presentation/page/pupils_classes_screen.dart';
import '../../features/common/data/data/user_me.dart';
import '../../features/devices/presentation/pages/devices_screen.dart';
import '../../features/hikvision/presentation/pages/hikvision_screen.dart';
import '../../features/organization/presentation/pages/organization_screen.dart';
import '../../features/users/presentation/pages/users_screen.dart';
import '../../features/users_comparison/presentation/bloc/users_comparison_bloc.dart';
import '../../features/users_comparison/presentation/pages/users_comparison_screen.dart';

String? _optionalRouteString(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  return s;
}

sealed class AppRoutes {
  // account
  static const String account = "/account";

  // auth
  static const String splash = '/';
  static const String signIn = '/sign_in';
  static const String pin = '/pin';

  // organization
  static const String organization = '/organization';

  // users
  static const String users = '/users';
  static const String usersComparison = '/users_comparison';

  // devices
  static const String devices = '/devices';

  // category selection
  static const String categorySelection = '/category_selection';
  static const String pupilsClasses = '/pupils_classes';
  static const String pupils = '/pupils';
  static const String employees = '/employees';

  // hikvision
  static const String hikvision = '/hikvision';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: _rootNavigatorKey,
  routes: [
    /// account
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) {
        final userMe = state.extra as UserMe;
        return AccountScreen(userMe: userMe);
      },
    ),

    /// splash gate
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const LaunchGateScreen(),
    ),

    /// auth
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.pin,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return PinScreen(isSetup: map['isSetup'] == true);
      },
    ),

    /// organization
    GoRoute(
      path: AppRoutes.organization,
      builder: (context, state) => const OrganizationScreen(),
    ),

    /// users
    GoRoute(
      path: AppRoutes.users,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return UsersScreen(
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          organizationId: (map['organizationId'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
        );
      },
    ),

    /// devices
    GoRoute(
      path: AppRoutes.devices,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return DevicesScreen(
          organizationId: (map['organizationId'] ?? '').toString(),
          organizationName: (map['organizationName'] ?? '').toString(),
        );
      },
    ),

    /// category selection
    GoRoute(
      path: AppRoutes.categorySelection,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return CategorySelectionScreen(
          organizationId: (map['organizationId'] ?? '').toString(),
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.pupilsClasses,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return PupilsClassesScreen(
          organizationId: (map['organizationId'] ?? '').toString(),
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.pupils,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return PupilsScreen(
          classId: (map['classId'] ?? '').toString(),
          organizationId: (map['organizationId'] ?? '').toString(),
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.employees,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return EmployeesScreen(
          organizationId: (map['organizationId'] ?? '').toString(),
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
        );
      },
    ),

    /// hikvision
    GoRoute(
      path: AppRoutes.hikvision,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return HikvisionScreen(
          employeeNo: (map['employeeNo'] ?? '').toString(),
          name: (map['name'] ?? '').toString(),
          hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
          hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
          hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          organizationId: (map['organizationId'] ?? '').toString(),
          deviceId: (map['deviceId'] ?? '').toString(),
          staffId: _optionalRouteString(map['staffId']),
          studentId: _optionalRouteString(map['studentId']),
          faceEnrollmentId: _optionalRouteString(map['faceEnrollmentId']),
          faceEnrollmentFileRelativeUrl: _optionalRouteString(map['faceEnrollmentFileRelativeUrl']),
        );
      },
    ),

    /// users comparison
    GoRoute(
      path: AppRoutes.usersComparison,
      builder: (context, state) {
        final extra = state.extra;
        final map = extra is Map ? extra : const <String, dynamic>{};
        return BlocProvider(
          create: (_) => UsersComparisonBloc(),
          child: UsersComparisonScreen(
            organizationId: (map['organizationId'] ?? '').toString(),
            hikvisionBaseUrl: (map['hikvisionBaseUrl'] ?? '').toString(),
            hikvisionUsername: (map['hikvisionUsername'] ?? '').toString(),
            hikvisionPassword: (map['hikvisionPassword'] ?? '').toString(),
          ),
        );
      },
    ),
  ],
);
