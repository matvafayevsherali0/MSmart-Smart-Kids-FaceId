import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/service_locator.dart';
import '../../data/data/employee.dart';
import '../../data/data/staff.dart';
import '../../domain/repository/users_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final _usersRepository = serviceLocator<UsersRepository>();
  String _organizationId = '';

  UsersBloc() : super(const UsersState()) {
    on<UsersListsStarted>(_onListsStarted);
    on<LoadMoreStaffEvent>(_onLoadMoreStaff);
    on<LoadMoreEmployeesEvent>(_onLoadMoreEmployees);
  }

  String _failureMessage(Object failure) {
    if (failure is Failure) {
      return failure.errorMessage ?? failure.toString();
    }
    return failure.toString();
  }

  FutureOr<void> _onListsStarted(UsersListsStarted event, Emitter<UsersState> emit) async {
    _organizationId = event.organizationId.trim();
    if (_organizationId.isEmpty) {
      emit(
        state.copyWith(
          staffList: const StaffListMessage('Tashkilot tanlanmagan.'),
          employeeList: const EmployeeListMessage('Tashkilot tanlanmagan.'),
        ),
      );
      return;
    }

    emit(state.copyWith(staffList: const StaffListLoading(), employeeList: const EmployeeListLoading()));

    final staffFuture = _usersRepository.getStaff(organizationId: _organizationId, page: 1);
    final employeeFuture = _usersRepository.getEmployee(organizationId: _organizationId, page: 1);

    final staffRes = await staffFuture;
    final employeeRes = await employeeFuture;

    emit(
      state.copyWith(
        staffList: staffRes.isRight
            ? StaffListContent(
                items: staffRes.right.items,
                page: staffRes.right.meta.page,
                hasMore: staffRes.right.meta.totalPages > staffRes.right.meta.page,
                isLoadingMore: false,
              )
            : StaffListMessage(_failureMessage(staffRes.left)),
        employeeList: employeeRes.isRight
            ? EmployeeListContent(
                items: employeeRes.right.items,
                page: employeeRes.right.meta.page,
                hasMore: employeeRes.right.meta.totalPages > employeeRes.right.meta.page,
                isLoadingMore: false,
              )
            : EmployeeListMessage(_failureMessage(employeeRes.left)),
      ),
    );
  }

  FutureOr<void> _onLoadMoreStaff(LoadMoreStaffEvent event, Emitter<UsersState> emit) async {
    final current = state.staffList;
    if (current is! StaffListContent) return;
    if (current.isLoadingMore || !current.hasMore) return;
    if (_organizationId.isEmpty) return;

    emit(state.copyWith(staffList: current.copyWith(isLoadingMore: true)));

    try {
      final nextPage = current.page + 1;
      final result = await _usersRepository.getStaff(organizationId: _organizationId, page: nextPage);
      if (result.isRight) {
        final r = result.right;
        if (r.items.isEmpty) {
          emit(state.copyWith(staffList: current.copyWith(isLoadingMore: false, hasMore: false)));
          return;
        }
        emit(
          state.copyWith(
            staffList: current.copyWith(
              items: [...current.items, ...r.items],
              page: r.meta.page,
              isLoadingMore: false,
              hasMore: r.meta.totalPages > r.meta.page,
            ),
          ),
        );
      } else {
        emit(state.copyWith(staffList: current.copyWith(isLoadingMore: false)));
      }
    } catch (_) {
      emit(state.copyWith(staffList: current.copyWith(isLoadingMore: false)));
    }
  }

  FutureOr<void> _onLoadMoreEmployees(LoadMoreEmployeesEvent event, Emitter<UsersState> emit) async {
    final current = state.employeeList;
    if (current is! EmployeeListContent) return;
    if (current.isLoadingMore || !current.hasMore) return;
    if (_organizationId.isEmpty) return;

    emit(state.copyWith(employeeList: current.copyWith(isLoadingMore: true)));

    try {
      final nextPage = current.page + 1;
      final result = await _usersRepository.getEmployee(organizationId: _organizationId, page: nextPage);
      if (result.isRight) {
        final r = result.right;
        if (r.items.isEmpty) {
          emit(state.copyWith(employeeList: current.copyWith(isLoadingMore: false, hasMore: false)));
          return;
        }
        emit(
          state.copyWith(
            employeeList: current.copyWith(
              items: [...current.items, ...r.items],
              page: r.meta.page,
              isLoadingMore: false,
              hasMore: r.meta.totalPages > r.meta.page,
            ),
          ),
        );
      } else {
        emit(state.copyWith(employeeList: current.copyWith(isLoadingMore: false)));
      }
    } catch (_) {
      emit(state.copyWith(employeeList: current.copyWith(isLoadingMore: false)));
    }
  }
}
