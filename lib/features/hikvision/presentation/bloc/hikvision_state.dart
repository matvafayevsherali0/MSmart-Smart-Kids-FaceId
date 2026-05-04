part of 'hikvision_bloc.dart';

@immutable
sealed class HikvisionState extends Equatable {
  const HikvisionState();

  @override
  List<Object?> get props => [];
}

class HikvisionInitial extends HikvisionState {
  const HikvisionInitial();
}

class HikvisionLoading extends HikvisionState {
  const HikvisionLoading();
}

class HikvisionUserFound extends HikvisionState {
  final HikvisionUser user;
  final List<int>? photoBytes;

  const HikvisionUserFound(this.user, {this.photoBytes});

  @override
  List<Object?> get props => [user, photoBytes];
}

class HikvisionUserNotFound extends HikvisionState {
  final String employeeNo;
  final String name;

  const HikvisionUserNotFound({required this.employeeNo, required this.name});

  @override
  List<Object?> get props => [employeeNo, name];
}

class HikvisionActionInProgress extends HikvisionState {
  const HikvisionActionInProgress();
}

class HikvisionSuccess extends HikvisionState {
  final String message;

  const HikvisionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HikvisionFailure extends HikvisionState {
  final String message;

  const HikvisionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
