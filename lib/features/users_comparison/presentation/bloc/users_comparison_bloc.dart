import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../face_enrollment/domain/repository/face_enrollment_repository.dart';
import '../../../hikvision/data/service/hikvision_service.dart';
import '../../../hikvision/domain/repository/hikvision_repository.dart';
import '../../domain/entity/backend_face_id_user.dart';
import '../../domain/entity/users_comparison_sync_plan.dart';
import '../../../users/domain/repository/users_repository.dart';

part 'users_comparison_event.dart';
part 'users_comparison_state.dart';

class UsersComparisonBloc
    extends Bloc<UsersComparisonEvent, UsersComparisonState> {
  final HikvisionRepository _hikvision = serviceLocator<HikvisionRepository>();
  final FaceEnrollmentRepository _faceEnrollment =
      serviceLocator<FaceEnrollmentRepository>();
  final UsersRepository _usersRepository = serviceLocator<UsersRepository>();
  String _organizationId = '';

  UsersComparisonBloc() : super(const UsersComparisonLoading()) {
    on<UsersComparisonStarted>(_onStarted);
    on<DataSynchronizationUsersComparisonEvent>(_onDataSynchronization);
    on<ApplyUsersComparisonSynchronizationEvent>(_onApplySynchronization);
    on<DeleteUsersComparisonEvent>(_onDeleteUsers);
  }

  Future<Either<Failure, List<BackendFaceIdUser>>> _loadAllStaff(
    String organizationId,
  ) async {
    final users = <BackendFaceIdUser>[];
    var page = 1;

    for (var request = 0; request < 500; request++) {
      final result = await _usersRepository.getStaff(
        organizationId: organizationId,
        page: page,
      );
      if (result.isLeft) return Left(result.left);

      final response = result.right;
      users.addAll(
        response.items
            .where((item) => item.id.trim().isNotEmpty)
            .map(
              (item) => BackendFaceIdUser(
                employeeNo: item.id,
                name: item.fullName,
                faceImageUrl: item.faceImageUrl,
              ),
            ),
      );

      final currentPage = response.meta.page > 0 ? response.meta.page : page;
      final totalPages = response.meta.totalPages;
      if (response.items.isEmpty ||
          (totalPages > 0 && currentPage >= totalPages) ||
          (totalPages <= 0 && response.items.length < 15)) {
        break;
      }
      page = currentPage + 1;
    }

    return Right(users);
  }

  Future<Either<Failure, List<BackendFaceIdUser>>> _loadAllEmployees(
    String organizationId,
  ) async {
    final users = <BackendFaceIdUser>[];
    var page = 1;

    for (var request = 0; request < 500; request++) {
      final result = await _usersRepository.getEmployee(
        organizationId: organizationId,
        page: page,
      );
      if (result.isLeft) return Left(result.left);

      final response = result.right;
      users.addAll(
        response.items
            .where((item) => item.id.trim().isNotEmpty)
            .map(
              (item) => BackendFaceIdUser(
                employeeNo: item.id,
                name: item.fullName,
                faceImageUrl: item.faceImageUrl,
              ),
            ),
      );

      final currentPage = response.meta.page > 0 ? response.meta.page : page;
      final totalPages = response.meta.totalPages;
      if (response.items.isEmpty ||
          (totalPages > 0 && currentPage >= totalPages) ||
          (totalPages <= 0 && response.items.length < 15)) {
        break;
      }
      page = currentPage + 1;
    }

    return Right(users);
  }

  Future<void> _onStarted(
    UsersComparisonStarted event,
    Emitter<UsersComparisonState> emit,
  ) async {
    emit(const UsersComparisonLoading());

    _organizationId = event.organizationId.trim();
    if (_organizationId.isEmpty) {
      emit(
        const UsersComparisonFailure(
          'Tashkilot ID berilmagan — solishtirish uchun organizationId kerak.',
        ),
      );
      return;
    }

    final staffRes = await _loadAllStaff(_organizationId);
    final employeeRes = await _loadAllEmployees(_organizationId);

    if (staffRes.isLeft && employeeRes.isLeft) {
      final sf = staffRes.left;
      final ef = employeeRes.left;
      emit(
        UsersComparisonFailure(
          '${sf.errorMessage ?? sf.toString()} | ${ef.errorMessage ?? ef.toString()}',
        ),
      );
      return;
    }

    if (staffRes.isLeft || employeeRes.isLeft) {
      final failure = staffRes.isLeft ? staffRes.left : employeeRes.left;
      emit(UsersComparisonFailure(failure.errorMessage ?? failure.toString()));
      return;
    }

    final staffUsers = staffRes.right;
    final employeeUsers = employeeRes.right;
    final backendUsersByNormalizedId = <String, BackendFaceIdUser>{};
    for (final user in [...staffUsers, ...employeeUsers]) {
      final normalizedId = HikvisionService.normalizeEmployeeNoForIsapi(
        user.employeeNo,
      );
      final current = backendUsersByNormalizedId[normalizedId];
      if (current == null) {
        backendUsersByNormalizedId[normalizedId] = user;
      } else {
        backendUsersByNormalizedId[normalizedId] = BackendFaceIdUser(
          employeeNo: current.employeeNo,
          name: current.name.trim().isEmpty ? user.name : current.name,
          faceImageUrl: current.faceImageUrl.trim().isEmpty
              ? user.faceImageUrl
              : current.faceImageUrl,
        );
      }
    }
    final backendUsers = backendUsersByNormalizedId.values.toList();
    final staffBackendIds = staffUsers.map((user) => user.employeeNo).toList();
    final employeeBackendIds = employeeUsers
        .map((user) => user.employeeNo)
        .toList();
    final backendIds = backendUsers.map((user) => user.employeeNo).toList();

    const pageSize = 30;
    final hikvisionIds = <String>[];
    var position = 0;
    var totalMatches = 0;
    var guard = 0;

    while (guard < 500) {
      guard++;
      final res = await _hikvision.searchUsers(
        searchResultPosition: position,
        maxResults: pageSize,
      );

      if (res.isLeft) {
        final f = res.left;
        emit(UsersComparisonFailure(f.errorMessage ?? f.toString()));
        return;
      }

      final chunk = res.right;
      totalMatches = chunk.totalMatches;
      hikvisionIds.addAll(chunk.users.map((e) => e.employeeNo));

      if (chunk.users.isEmpty ||
          (totalMatches > 0 && hikvisionIds.length >= totalMatches)) {
        break;
      }
      position += chunk.users.length;
    }

    emit(
      UsersComparisonContent(
        staffBackendIds: staffBackendIds,
        employeeBackendIds: employeeBackendIds,
        backendIds: backendIds,
        backendUsers: backendUsers,
        hikvisionIds: hikvisionIds,
      ),
    );
  }

  Future<void> _onDataSynchronization(
    DataSynchronizationUsersComparisonEvent event,
    Emitter<UsersComparisonState> emit,
  ) async {
    if (state is! UsersComparisonContent) return;
    final current = state as UsersComparisonContent;

    final backendUsers = current.backendUsers.isNotEmpty
        ? current.backendUsers
        : event.backendIds
              .map((id) => BackendFaceIdUser(employeeNo: id, name: id))
              .toList();
    final plan = UsersComparisonSyncPlan.build(
      backendUsers: backendUsers,
      hikvisionEmployeeNos: event.hikvisionIds,
    );

    emit(
      current.copyWith(
        backendUsersToCreate: plan.backendUsersToCreate,
        usersComparisonIds: plan.hikvisionUsersToDelete,
        isSynchronizing: true,
        isApplying: false,
      ),
    );
  }

  Future<void> _onApplySynchronization(
    ApplyUsersComparisonSynchronizationEvent event,
    Emitter<UsersComparisonState> emit,
  ) async {
    if (state is! UsersComparisonContent) return;
    final current = state as UsersComparisonContent;
    if (!current.isSynchronizing || current.isApplying) return;

    emit(current.copyWith(isApplying: true));

    for (final user in current.backendUsersToCreate) {
      final result = await _hikvision.createUser(
        employeeNo: user.employeeNo,
        name: user.displayName,
      );
      if (result.isLeft) {
        final failure = result.left;
        emit(
          UsersComparisonFailure(
            '"${user.displayName}" Face ID qurilmasiga qo‘shilmadi: '
            '${failure.errorMessage ?? failure.toString()}',
          ),
        );
        return;
      }
    }

    for (final user in current.backendUsers) {
      final relativeImageUrl = user.faceImageUrl.trim();
      if (relativeImageUrl.isEmpty) continue;

      final imageResult = await _faceEnrollment.downloadFaceImageBytes(
        relativeImageUrl,
      );
      if (imageResult.isLeft) {
        final failure = imageResult.left;
        emit(
          UsersComparisonFailure(
            '"${user.displayName}" rasmi backenddan yuklanmadi: '
            '${failure.errorMessage ?? failure.toString()}',
          ),
        );
        return;
      }

      final result = await _hikvision.upsertFaceByBytes(
        employeeNo: user.employeeNo,
        imageBytes: imageResult.right,
        name: user.displayName,
      );
      if (result.isLeft) {
        final failure = result.left;
        emit(
          UsersComparisonFailure(
            '"${user.displayName}" rasmi Face ID qurilmasiga qo‘shilmadi: '
            '${failure.errorMessage ?? failure.toString()}',
          ),
        );
        return;
      }
    }

    if (current.usersComparisonIds.isNotEmpty) {
      final result = await _hikvision.deleteUsersBatch(
        current.usersComparisonIds,
      );
      if (result.isLeft) {
        final failure = result.left;
        emit(
          UsersComparisonFailure(
            'Face ID qurilmasidagi ortiqcha foydalanuvchilar o‘chirilmadi: '
            '${failure.errorMessage ?? failure.toString()}',
          ),
        );
        return;
      }
    }

    final deletedIds = current.usersComparisonIds
        .map(HikvisionService.normalizeEmployeeNoForIsapi)
        .toSet();
    final updatedHikvisionIds = <String>{
      ...current.hikvisionIds.map(HikvisionService.normalizeEmployeeNoForIsapi),
      ...current.backendUsersToCreate.map(
        (user) => HikvisionService.normalizeEmployeeNoForIsapi(user.employeeNo),
      ),
    }..removeAll(deletedIds);

    emit(
      current.copyWith(
        hikvisionIds: updatedHikvisionIds.toList(),
        backendUsersToCreate: const [],
        usersComparisonIds: const [],
        isSynchronizing: false,
        isApplying: false,
      ),
    );
  }

  Future<void> _onDeleteUsers(
    DeleteUsersComparisonEvent event,
    Emitter<UsersComparisonState> emit,
  ) async {
    if (state is! UsersComparisonContent) return;
    final current = state as UsersComparisonContent;

    if (current.usersComparisonIds.isEmpty) return;

    final result = await _hikvision.deleteUsersBatch(
      current.usersComparisonIds,
    );
    if (result.isLeft) {
      final f = result.left;
      emit(UsersComparisonFailure(f.errorMessage ?? f.toString()));
      return;
    }

    emit(
      current.copyWith(
        usersComparisonIds: const [],
        isSynchronizing: false,
        isApplying: false,
      ),
    );
  }
}
