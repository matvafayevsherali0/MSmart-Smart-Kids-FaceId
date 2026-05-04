part of 'account_bloc.dart';

enum AccountActionStatus {
  idle,
  loading,
  logoutSuccess,
  deleteLinkOpened,
  failure,
}

class AccountState {
  final AccountActionStatus status;
  final String? errorMessage;

  const AccountState({
    this.status = AccountActionStatus.idle,
    this.errorMessage,
  });

  AccountState copyWith({
    AccountActionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

