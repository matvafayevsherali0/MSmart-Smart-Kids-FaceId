part of 'users_bloc.dart';

@immutable
sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class UsersListsStarted extends UsersEvent {
  final String organizationId;

  const UsersListsStarted(this.organizationId);

  @override
  List<Object?> get props => [organizationId];
}

class LoadMoreStaffEvent extends UsersEvent {
  const LoadMoreStaffEvent();
}

class LoadMoreEmployeesEvent extends UsersEvent {
  const LoadMoreEmployeesEvent();
}
