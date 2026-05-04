import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/service_locator.dart';
import '../../../auth/domain/repository/auth_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final _authRepository = serviceLocator<AuthRepository>();
  static final Uri _deleteAccountUri = Uri.parse('https://smartboshqaruv.uz/delete-account');

  AccountBloc() : super(const AccountState()) {
    on<AccountLogoutRequested>(_onLogoutRequested);
    on<AccountDeleteLinkOpenRequested>(_onDeleteLinkOpenRequested);
  }

  Future<void> _onLogoutRequested(AccountLogoutRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(status: AccountActionStatus.loading, clearError: true));
    final result = await _authRepository.logout();
    if (result.isRight) {
      emit(state.copyWith(status: AccountActionStatus.logoutSuccess, clearError: true));
    } else {
      emit(
        state.copyWith(
          status: AccountActionStatus.failure,
          errorMessage: result.left.errorMessage ?? "Chiqishda xatolik yuz berdi",
        ),
      );
    }
  }

  Future<void> _onDeleteLinkOpenRequested(
    AccountDeleteLinkOpenRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountActionStatus.loading, clearError: true));
    final opened = await launchUrl(_deleteAccountUri, mode: LaunchMode.externalApplication);
    if (opened) {
      emit(state.copyWith(status: AccountActionStatus.deleteLinkOpened, clearError: true));
    } else {
      emit(
        state.copyWith(
          status: AccountActionStatus.failure,
          errorMessage: "Havolani ochib bo'lmadi",
        ),
      );
    }
  }
}
