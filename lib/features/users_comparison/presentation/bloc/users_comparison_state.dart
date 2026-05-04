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
  final List<String> hikvisionIds;
  final List<String> usersComparisonIds;
  final bool isSynchronizing;

  const UsersComparisonContent({
    this.staffBackendIds = const [],
    this.employeeBackendIds = const [],
    required this.backendIds,
    required this.hikvisionIds,
    this.usersComparisonIds = const [],
    this.isSynchronizing = false,
  });

  UsersComparisonContent copyWith({
    List<String>? staffBackendIds,
    List<String>? employeeBackendIds,
    List<String>? backendIds,
    List<String>? hikvisionIds,
    List<String>? usersComparisonIds,
    bool? isSynchronizing,
  }) {
    return UsersComparisonContent(
      staffBackendIds: staffBackendIds ?? this.staffBackendIds,
      employeeBackendIds: employeeBackendIds ?? this.employeeBackendIds,
      backendIds: backendIds ?? this.backendIds,
      hikvisionIds: hikvisionIds ?? this.hikvisionIds,
      usersComparisonIds: usersComparisonIds ?? this.usersComparisonIds,
      isSynchronizing: isSynchronizing ?? this.isSynchronizing,
    );
  }

  @override
  List<Object?> get props => [
        staffBackendIds,
        employeeBackendIds,
        backendIds,
        hikvisionIds,
        usersComparisonIds,
        isSynchronizing,
      ];
}

class UsersComparisonFailure extends UsersComparisonState {
  final String message;

  const UsersComparisonFailure(this.message);

  @override
  List<Object?> get props => [message];
}
