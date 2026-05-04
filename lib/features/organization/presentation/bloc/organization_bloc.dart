import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../../../core/utils/service_locator.dart';
import '../../domain/repository/organization_repository.dart';
import 'organization_state.dart';

part 'organization_event.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  final _organizationRepository = serviceLocator<OrganizationRepository>();

  OrganizationBloc() : super(OrganizationState()) {
    on<GetOrganizationsEvent>(_onGetOrganizations);
    /*on<LoadMoreOrganizationsEvent>(_onLoadMoreOrganizations);*/
  }

  FutureOr<void> _onGetOrganizations(GetOrganizationsEvent event, Emitter<OrganizationState> emit) async {
    try {
      emit(state.copyWith(organizationData: OrganizationsDataLoading()));
      final result = await _organizationRepository.getUserMe();
      if (result.isRight) {
        emit(
          state.copyWith(
            organizationData: OrganizationsDataContent(organizations: result.right.organizations),
            userMe: result.right,
          ),
        );
      } else {
        emit(state.copyWith(organizationData: OrganizationsDataMessageContent(content: """"${result.left}""")));
      }
    } catch (e) {
      emit(state.copyWith(organizationData: OrganizationsDataMessageContent(content: """$e""")));
    }
  }

  /*FutureOr<void> _onLoadMoreOrganizations(LoadMoreOrganizationsEvent event, Emitter<OrganizationState> emit) async {
    final current = state.organizationData;
    if (current is! OrganizationsDataContent) return;
    if (current.isLoadingMore) return;
    emit(state.copyWith(organizationData: current.copyWith(isLoadingMore: true)));
    try {
      final nextPage = current.page + 1;
      final result = await _organizationRepository.getOrganizations(page: nextPage);
      if (result.isRight) {
        final org = result.right;
        if (org.items.isEmpty) {
          emit(state.copyWith(organizationData: current.copyWith(isLoadingMore: false)));
          return;
        }
        final updated = current.copyWith(
          organizations: [...current.organizations, ...org.items],
          page: org.meta.page,
          isLoadingMore: org.meta.totalPages > org.meta.page,
        );
        emit(state.copyWith(organizationData: updated));
      } else {
        emit(state.copyWith(organizationData: current.copyWith(isLoadingMore: false)));
      }
    } catch (e) {
      emit(state.copyWith(organizationData: current.copyWith(isLoadingMore: false)));
    }
  }*/
}
