part of 'users_comparison_bloc.dart';

@immutable
sealed class UsersComparisonState extends Equatable {
  const UsersComparisonState();

  @override
  List<Object?> get props => [];
}

class UsersComparisonLoading extends UsersComparisonState {
  const UsersComparisonLoading();
}

class UsersComparisonContent extends UsersComparisonState {
  final List<String> staffBackendIds;
  final List<String> employeeBackendIds;
  final List<String> backendIds;
  final List<BackendFaceIdUser> backendUsers;
  final List<String> hikvisionIds;
  final List<BackendFaceIdUser> backendUsersToCreate;
  final List<String> usersComparisonIds;
  final bool isSynchronizing;
  final bool isApplying;

  const UsersComparisonContent({
    this.staffBackendIds = const [],
    this.employeeBackendIds = const [],
    required this.backendIds,
    this.backendUsers = const [],
    required this.hikvisionIds,
    this.backendUsersToCreate = const [],
    this.usersComparisonIds = const [],
    this.isSynchronizing = false,
    this.isApplying = false,
  });

  UsersComparisonContent copyWith({
    List<String>? staffBackendIds,
    List<String>? employeeBackendIds,
    List<String>? backendIds,
    List<BackendFaceIdUser>? backendUsers,
    List<String>? hikvisionIds,
    List<BackendFaceIdUser>? backendUsersToCreate,
    List<String>? usersComparisonIds,
    bool? isSynchronizing,
    bool? isApplying,
  }) {
    return UsersComparisonContent(
      staffBackendIds: staffBackendIds ?? this.staffBackendIds,
      employeeBackendIds: employeeBackendIds ?? this.employeeBackendIds,
      backendIds: backendIds ?? this.backendIds,
      backendUsers: backendUsers ?? this.backendUsers,
      hikvisionIds: hikvisionIds ?? this.hikvisionIds,
      backendUsersToCreate: backendUsersToCreate ?? this.backendUsersToCreate,
      usersComparisonIds: usersComparisonIds ?? this.usersComparisonIds,
      isSynchronizing: isSynchronizing ?? this.isSynchronizing,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  List<Object?> get props => [
    staffBackendIds,
    employeeBackendIds,
    backendIds,
    backendUsers,
    hikvisionIds,
    backendUsersToCreate,
    usersComparisonIds,
    isSynchronizing,
    isApplying,
  ];
}

class UsersComparisonFailure extends UsersComparisonState {
  final String message;

  const UsersComparisonFailure(this.message);

  @override
  List<Object?> get props => [message];
}
