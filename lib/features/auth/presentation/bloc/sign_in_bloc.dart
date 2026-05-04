import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../domain/entity/sign_in_request.dart';
import '../../domain/repository/auth_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final _authRepository = serviceLocator<AuthRepository>();
  final _storage = serviceLocator<StorageRepository>();

  SignInBloc() : super(SignInState()) {
    on<SignInWithLogin>(onSignInWithLogin);
    on<HideEyeSignInEvent>(onHideEye);
    on<IsDisableButtonSignInWithLogin>(_onIsDisableButton);
  }

  FutureOr<void> onSignInWithLogin(SignInWithLogin event, Emitter<SignInState> emit) async {
    if (state.isLoading) return;
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _authRepository.signIn(
        signInRequest: SignInRequest(
          phone: event.login.replaceAll(' ', ''),
          password: event.password.replaceAll(' ', ''),
          fcmToken: _storage.getString(StoreKeys.firebaseToken),
        ),
      );
      emit(state.copyWith(isLoading: false));
      if (result.isRight) {
        event.onSuccess.call();
      } else {
        event.onError("""${result.left}""");
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      event.onError("""$e""");
    }
  }

  FutureOr<void> onHideEye(HideEyeSignInEvent event, Emitter<SignInState> emit) {
    emit(state.copyWith(isHidePassword: !state.isHidePassword));
  }

  FutureOr<void> _onIsDisableButton(IsDisableButtonSignInWithLogin event, Emitter<SignInState> emit) {
    emit(state.copyWith(isDisable: event.login.length > 3 && event.password.length > 3));
  }
}
