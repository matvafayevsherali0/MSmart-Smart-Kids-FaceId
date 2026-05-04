import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/utils/service_locator.dart';
import '../../../hikvision/data/service/hikvision_service.dart';
import '../../../hikvision/domain/repository/hikvision_repository.dart';
import '../../../users/domain/repository/users_repository.dart';

part 'users_comparison_event.dart';
part 'users_comparison_state.dart';

class UsersComparisonBloc extends Bloc<UsersComparisonEvent, UsersComparisonState> {
  final HikvisionRepository _hikvision = serviceLocator<HikvisionRepository>();
  final UsersRepository _usersRepository = serviceLocator<UsersRepository>();

  UsersComparisonBloc() : super(const UsersComparisonLoading()) {
    on<UsersComparisonStarted>(_onStarted);
    on<DataSynchronizationUsersComparisonEvent>(_onDataSynchronization);
    on<DeleteUsersComparisonEvent>(_onDeleteUsers);
  }

  Future<void> _onStarted(UsersComparisonStarted event, Emitter<UsersComparisonState> emit) async {
    emit(const UsersComparisonLoading());

    final orgId = event.organizationId.trim();
    if (orgId.isEmpty) {
      emit(const UsersComparisonFailure('Tashkilot ID berilmagan — solishtirish uchun organizationId kerak.'));
      return;
    }

    final staffRes = await _usersRepository.getStaffIds(organizationId: orgId);
    final employeeRes = await _usersRepository.getEmployeeIds(organizationId: orgId);

    if (staffRes.isLeft && employeeRes.isLeft) {
      final sf = staffRes.left;
      final ef = employeeRes.left;
      emit(UsersComparisonFailure('${sf.errorMessage ?? sf.toString()} | ${ef.errorMessage ?? ef.toString()}'));
      return;
    }

    final List<String> staffBackendIds = staffRes.isRight ? List<String>.from(staffRes.right) : <String>[];
    final List<String> employeeBackendIds = employeeRes.isRight ? List<String>.from(employeeRes.right) : <String>[];
    final backendIds = <String>{...staffBackendIds, ...employeeBackendIds}.toList();

    const pageSize = 30;
    final hikvisionIds = <String>[];
    var position = 0;
    var totalMatches = 0;
    var guard = 0;

    while (guard < 500) {
      guard++;
      final res = await _hikvision.searchUsers(searchResultPosition: position, maxResults: pageSize);

      if (res.isLeft) {
        final f = res.left;
        emit(UsersComparisonFailure(f.errorMessage ?? f.toString()));
        return;
      }

      final chunk = res.right;
      totalMatches = chunk.totalMatches;
      hikvisionIds.addAll(chunk.users.map((e) => e.employeeNo));

      if (chunk.users.isEmpty || hikvisionIds.length >= totalMatches) {
        break;
      }
      position += chunk.users.length;
    }

    emit(
      UsersComparisonContent(
        staffBackendIds: staffBackendIds,
        employeeBackendIds: employeeBackendIds,
        backendIds: backendIds,
        hikvisionIds: hikvisionIds,
      ),
    );
  }

  FutureOr<void> _onDataSynchronization(DataSynchronizationUsersComparisonEvent event, Emitter<UsersComparisonState> emit) async {
    if (state is! UsersComparisonContent) return;
    final current = state as UsersComparisonContent;

    final backendSet = event.backendIds.map(HikvisionService.normalizeEmployeeNoForIsapi).toSet();
    final usersComparisonIds = <String>[];

    for (final id in event.hikvisionIds) {
      final normalized = HikvisionService.normalizeEmployeeNoForIsapi(id);
      if (!backendSet.contains(normalized)) {
        usersComparisonIds.add(id);
      }
    }

    emit(current.copyWith(usersComparisonIds: usersComparisonIds, isSynchronizing: true));
  }

  FutureOr<void> _onDeleteUsers(DeleteUsersComparisonEvent event, Emitter<UsersComparisonState> emit) async {
    if (state is! UsersComparisonContent) return;
    final current = state as UsersComparisonContent;

    if (current.usersComparisonIds.isEmpty) return;

    final result = await _hikvision.deleteUsersBatch(current.usersComparisonIds);
    if (result.isLeft) {
      final f = result.left;
      emit(UsersComparisonFailure(f.errorMessage ?? f.toString()));
      return;
    }

    emit(current.copyWith(usersComparisonIds: const [], isSynchronizing: false));
  }
}
