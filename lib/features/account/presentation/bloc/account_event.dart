part of 'account_bloc.dart';

@immutable
sealed class AccountEvent {}

class AccountLogoutRequested extends AccountEvent {}

class AccountDeleteLinkOpenRequested extends AccountEvent {}
