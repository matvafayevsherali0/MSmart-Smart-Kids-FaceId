part of 'users_comparison_bloc.dart';

@immutable
sealed class UsersComparisonEvent extends Equatable {
  const UsersComparisonEvent();

  @override
  List<Object?> get props => [];
}

class UsersComparisonStarted extends UsersComparisonEvent {
  final String organizationId;

  const UsersComparisonStarted({required this.organizationId});

  @override
  List<Object?> get props => [organizationId];
}

class DataSynchronizationUsersComparisonEvent extends UsersComparisonEvent {
  final List<String> backendIds;
  final List<String> hikvisionIds;

  const DataSynchronizationUsersComparisonEvent({
    required this.backendIds,
    required this.hikvisionIds,
  });

  @override
  List<Object?> get props => [backendIds, hikvisionIds];
}

class DeleteUsersComparisonEvent extends UsersComparisonEvent {
  final List<String> employeeNos;

  const DeleteUsersComparisonEvent(this.employeeNos);

  @override
  List<Object?> get props => [employeeNos];
}
