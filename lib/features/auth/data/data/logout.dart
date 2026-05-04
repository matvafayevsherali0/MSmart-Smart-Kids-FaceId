import 'package:equatable/equatable.dart';

class Logout extends Equatable {
  final bool isSuccess;
  final String message;

  const Logout({this.isSuccess = false, this.message = ''});

  @override
  List<Object?> get props => [isSuccess, message];
}
