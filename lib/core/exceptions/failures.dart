import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? errorMessage;
  final String? errorKey;

  const Failure({this.errorMessage, this.errorKey});

  @override
  List<Object?> get props => [errorMessage, errorKey];
}

class AppFailure extends Failure {
  const AppFailure({super.errorMessage, super.errorKey});
}
