import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/exceptions/failures.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../face_enrollment/domain/repository/face_enrollment_repository.dart';
import '../../data/service/hikvision_service.dart';
import '../../domain/entity/hikvision_user.dart';
import '../../domain/repository/hikvision_repository.dart';

part 'hikvision_event.dart';
part 'hikvision_state.dart';

class HikvisionBloc extends Bloc<HikvisionEvent, HikvisionState> {
  final _repository = serviceLocator<HikvisionRepository>();
  final _faceEnrollment = serviceLocator<FaceEnrollmentRepository>();
  String? _lastCapturedEmployeeNo;
  List<int>? _lastCapturedFaceBytes;
  final _faceEnrollmentIdsByEmployeeNo = <String, String>{};

  HikvisionBloc() : super(const HikvisionInitial()) {
    on<HikvisionStarted>(_onStarted);
    on<HikvisionCreateUserPressed>(_onCreateUserPressed);
    on<HikvisionAddPhotoPressed>(_onAddPhotoPressed);
    on<HikvisionDeleteUserPressed>(_onDeleteUserPressed);
  }

  String _employeeKey(String employeeNo) =>
      HikvisionService.normalizeEmployeeNoForIsapi(employeeNo);

  String? _faceEnrollmentIdFor(String employeeNo) {
    final id = _faceEnrollmentIdsByEmployeeNo[_employeeKey(employeeNo)];
    return id == null || id.trim().isEmpty ? null : id.trim();
  }

  void _rememberFaceEnrollmentId(String employeeNo, String? id) {
    final key = _employeeKey(employeeNo);
    final value = id?.trim() ?? '';
    if (key.isEmpty || value.isEmpty) return;
    _faceEnrollmentIdsByEmployeeNo[key] = value;
  }

  Future<void> _markDeviceSyncFailure({
    required String faceEnrollmentId,
    required String deviceId,
    required String message,
  }) async {
    if (faceEnrollmentId.trim().isEmpty || deviceId.trim().isEmpty) return;
    final result = await _faceEnrollment.updateDeviceSync(
      faceEnrollmentId: faceEnrollmentId,
      deviceId: deviceId,
      isSynced: false,
      errorMessage: message,
    );
    if (result.isLeft) {
      debugPrint(
        '[Hikvision] Backend device-sync holatini yangilab bo‘lmadi: '
        '${result.left.errorMessage ?? result.left}',
      );
    }
  }

  HikvisionStarted _restartAfterPhoto(
    HikvisionAddPhotoPressed event, {
    String? faceEnrollmentId,
  }) {
    return HikvisionStarted(
      employeeNo: event.lookupEmployeeNo,
      name: '',
      faceEnrollmentId: faceEnrollmentId,
      studentId: event.studentId,
      staffId: event.staffId,
      organizationId: event.organizationId,
    );
  }

  Future<void> _onStarted(
    HikvisionStarted event,
    Emitter<HikvisionState> emit,
  ) async {
    emit(const HikvisionLoading());
    _rememberFaceEnrollmentId(event.employeeNo, event.faceEnrollmentId);
    var faceEnrollmentId = _faceEnrollmentIdFor(event.employeeNo);
    if (faceEnrollmentId == null) {
      final studentId = event.studentId?.trim() ?? '';
      final staffId = event.staffId?.trim() ?? '';
      final organizationId = event.organizationId?.trim() ?? '';
      final ownerId = studentId.isNotEmpty ? studentId : staffId;
      final ownerType = studentId.isNotEmpty ? 'student' : 'staff';
      if (ownerId.isNotEmpty && organizationId.isNotEmpty) {
        final lookupResult = await _faceEnrollment.findFaceEnrollmentId(
          ownerType: ownerType,
          ownerId: ownerId,
          organizationId: organizationId,
        );
        if (lookupResult.isRight) {
          faceEnrollmentId = lookupResult.right;
          _rememberFaceEnrollmentId(event.employeeNo, faceEnrollmentId);
        } else {
          final message =
              lookupResult.left.errorMessage ?? lookupResult.left.toString();
          debugPrint(
            '[Hikvision] Backend face enrollment ID lookup xatosi: $message',
          );
          emit(
            const HikvisionFailure(
              'Backenddagi Face ID ma’lumotini tekshirib bo‘lmadi. Internetni tekshirib, qayta urinib ko‘ring.',
            ),
          );
          return;
        }
      }
    }
    final result = await _repository.getUserByEmployeeNo(event.employeeNo);
    if (result.isRight) {
      final user = result.right;
      if (user != null) {
        if (_lastCapturedEmployeeNo == user.employeeNo &&
            _lastCapturedFaceBytes != null) {
          emit(
            HikvisionUserFound(
              user,
              photoBytes: _lastCapturedFaceBytes,
              faceEnrollmentId: faceEnrollmentId,
            ),
          );
          return;
        }
        final faceUrlResult = await _repository.getFaceUrlByEmployeeNo(
          user.employeeNo,
        );
        if (faceUrlResult.isRight) {
          final url = faceUrlResult.right;
          if (url != null && url.isNotEmpty) {
            final bytesResult = await _repository.downloadBytesWithDigest(
              Uri.parse(url),
            );
            if (bytesResult.isRight) {
              emit(
                HikvisionUserFound(
                  user,
                  photoBytes: bytesResult.right,
                  faceEnrollmentId: faceEnrollmentId,
                ),
              );
              return;
            }
          }
        }

        final rel = event.faceEnrollmentFileRelativeUrl?.trim() ?? '';
        if (rel.isNotEmpty) {
          final backendImageResult = await _faceEnrollment
              .downloadFaceImageBytes(rel);
          if (backendImageResult.isLeft) {
            debugPrint(
              '[Hikvision] Backend rasmi yuklanmadi: '
              '${backendImageResult.left.errorMessage ?? backendImageResult.left}',
            );
          } else {
            final addResult = await _repository.upsertFaceByBytes(
              employeeNo: user.employeeNo,
              imageBytes: backendImageResult.right,
              name: user.name,
            );
            if (addResult.isLeft) {
              debugPrint(
                '[Hikvision] Backend rasmi Face ID ga yuborilmadi: '
                '${addResult.left.errorMessage ?? addResult.left}',
              );
            }
          }
          final after = await _repository.getFaceUrlByEmployeeNo(
            user.employeeNo,
          );
          if (after.isRight) {
            final u = after.right;
            if (u != null && u.isNotEmpty) {
              final bytesResult = await _repository.downloadBytesWithDigest(
                Uri.parse(u),
              );
              if (bytesResult.isRight) {
                emit(
                  HikvisionUserFound(
                    user,
                    photoBytes: bytesResult.right,
                    faceEnrollmentId: faceEnrollmentId,
                  ),
                );
                return;
              }
            }
          }
        }

        emit(HikvisionUserFound(user, faceEnrollmentId: faceEnrollmentId));
      } else {
        emit(
          HikvisionUserNotFound(employeeNo: event.employeeNo, name: event.name),
        );
      }
    } else {
      final failure = result.left;
      emit(HikvisionFailure(failure.errorMessage ?? failure.toString()));
    }
  }

  Future<void> _onCreateUserPressed(
    HikvisionCreateUserPressed event,
    Emitter<HikvisionState> emit,
  ) async {
    emit(const HikvisionActionInProgress());
    final result = await _repository.createUser(
      employeeNo: event.employeeNo,
      name: event.name,
    );
    if (result.isRight) {
      emit(
        const HikvisionSuccess(
          'Foydalanuvchi Hikvision ga muvaffaqiyatli qo‘shildi',
        ),
      );
      add(
        HikvisionStarted(
          employeeNo: event.employeeNo,
          name: event.name,
          faceEnrollmentId: _faceEnrollmentIdFor(event.employeeNo),
        ),
      );
    } else {
      final Failure failure = result.left;
      emit(HikvisionFailure(failure.errorMessage ?? failure.toString()));
    }
  }

  Future<void> _onAddPhotoPressed(
    HikvisionAddPhotoPressed event,
    Emitter<HikvisionState> emit,
  ) async {
    debugPrint(
      '[Hikvision] Bloc rasm olish boshlandi: '
      'employeeNo=${event.deviceEmployeeNo}, '
      'lookupEmployeeNo=${event.lookupEmployeeNo}',
    );
    emit(const HikvisionActionInProgress());

    final captureResult = await _repository.captureFaceBytes();
    if (captureResult.isLeft) {
      final f = captureResult.left;
      debugPrint('[Hikvision] Bloc rasm olish xatosi: ${f.errorMessage ?? f}');
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }

    final faceBytes = captureResult.right;
    debugPrint('[Hikvision] Bloc rasm olindi: ${faceBytes.length} bayt');
    final sid = event.studentId?.trim() ?? '';
    final stid = event.staffId?.trim() ?? '';
    final orgId = event.organizationId?.trim() ?? '';
    final devId = event.deviceId?.trim() ?? '';
    final hasOwnerId = sid.isNotEmpty || stid.isNotEmpty;
    final syncBackend = hasOwnerId && orgId.isNotEmpty && devId.isNotEmpty;
    final existingFaceEnrollmentId =
        event.faceEnrollmentId?.trim().isNotEmpty == true
        ? event.faceEnrollmentId!.trim()
        : _faceEnrollmentIdFor(event.lookupEmployeeNo);
    _rememberFaceEnrollmentId(event.lookupEmployeeNo, existingFaceEnrollmentId);

    final addResult = await _repository.upsertFaceByBytes(
      employeeNo: event.deviceEmployeeNo,
      imageBytes: faceBytes,
      name: event.name,
    );
    if (addResult.isLeft) {
      final f = addResult.left;
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }
    _lastCapturedEmployeeNo = event.deviceEmployeeNo;
    _lastCapturedFaceBytes = faceBytes;

    if (syncBackend) {
      try {
        final uploadResult = await _faceEnrollment.uploadFaceImageBytes(
          faceBytes,
        );
        if (uploadResult.isLeft) {
          final f = uploadResult.left;
          emit(
            HikvisionFailure(
              'Qurilmaga rasm qo‘shildi, POST /api/file xatosi: ${f.errorMessage ?? f}',
            ),
          );
          add(
            _restartAfterPhoto(
              event,
              faceEnrollmentId: existingFaceEnrollmentId,
            ),
          );
          return;
        }

        String? backendFaceEnrollmentId;
        if (existingFaceEnrollmentId == null) {
          final enrollResult = await _faceEnrollment.enrollFromDevice(
            studentId: sid.isNotEmpty ? sid : null,
            staffId: stid.isNotEmpty ? stid : null,
            faceImageId: uploadResult.right,
            organizationId: orgId,
            deviceId: devId,
          );
          if (enrollResult.isLeft) {
            final f = enrollResult.left;
            final message = f.errorMessage ?? f.toString();
            emit(
              HikvisionFailure(
                'Qurilmaga rasm qo‘shildi, lekin backendda saqlanmadi: $message',
              ),
            );
            add(_restartAfterPhoto(event));
            return;
          }
          backendFaceEnrollmentId = enrollResult.right;
        } else {
          final updateResult = await _faceEnrollment.updateFaceEnrollment(
            id: existingFaceEnrollmentId,
            faceImageId: uploadResult.right,
          );
          if (updateResult.isLeft) {
            final f = updateResult.left;
            final message = f.errorMessage ?? f.toString();
            await _markDeviceSyncFailure(
              faceEnrollmentId: existingFaceEnrollmentId,
              deviceId: devId,
              message: message,
            );
            emit(
              HikvisionFailure(
                'Qurilmaga rasm qo‘shildi, lekin backendda yangilanmadi: $message',
              ),
            );
            add(
              HikvisionStarted(
                employeeNo: event.lookupEmployeeNo,
                name: '',
                faceEnrollmentId: existingFaceEnrollmentId,
                studentId: event.studentId,
                staffId: event.staffId,
                organizationId: event.organizationId,
              ),
            );
            return;
          }
          backendFaceEnrollmentId = existingFaceEnrollmentId;

          final syncResult = await _faceEnrollment.updateDeviceSync(
            faceEnrollmentId: existingFaceEnrollmentId,
            deviceId: devId,
            isSynced: true,
          );
          if (syncResult.isLeft) {
            final f = syncResult.left;
            final message = f.errorMessage ?? f.toString();
            emit(
              HikvisionFailure(
                'Backenddagi rasm yangilandi, lekin qurilma sinxronligi tasdiqlanmadi: $message',
              ),
            );
            add(
              _restartAfterPhoto(
                event,
                faceEnrollmentId: existingFaceEnrollmentId,
              ),
            );
            return;
          }
        }
        _rememberFaceEnrollmentId(
          event.lookupEmployeeNo,
          backendFaceEnrollmentId,
        );
      } catch (e) {
        emit(
          HikvisionFailure(
            'Qurilmaga rasm qo‘shildi, backend sinxron xatosi: $e',
          ),
        );
        add(
          _restartAfterPhoto(event, faceEnrollmentId: existingFaceEnrollmentId),
        );
        return;
      }
    }

    emit(const HikvisionSuccess('Rasm muvaffaqiyatli qo‘shildi'));
    add(_restartAfterPhoto(event, faceEnrollmentId: existingFaceEnrollmentId));
  }

  Future<void> _onDeleteUserPressed(
    HikvisionDeleteUserPressed event,
    Emitter<HikvisionState> emit,
  ) async {
    emit(const HikvisionActionInProgress());

    final faceEnrollmentId = event.faceEnrollmentId?.trim().isNotEmpty == true
        ? event.faceEnrollmentId!.trim()
        : _faceEnrollmentIdFor(event.employeeNo);
    final deviceId = event.deviceId.trim();
    if (faceEnrollmentId == null || faceEnrollmentId.isEmpty) {
      emit(
        const HikvisionFailure(
          'Backenddagi face enrollment ID topilmadi. Sinxronlikni saqlash uchun avval backenddagi ma’lumotni yangilang.',
        ),
      );
      return;
    }
    if (deviceId.isEmpty) {
      emit(
        const HikvisionFailure(
          'Face ID qurilmasi ID topilmadi. Backend bilan birga o‘chirish uchun qurilmani qayta tanlang.',
        ),
      );
      return;
    }

    final result = await _repository.deleteUser(event.employeeNo);
    if (result.isLeft) {
      final f = result.left;
      await _markDeviceSyncFailure(
        faceEnrollmentId: faceEnrollmentId,
        deviceId: deviceId,
        message: f.errorMessage ?? f.toString(),
      );
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }

    final deleteEnrollmentResult = await _faceEnrollment.deleteFaceEnrollment(
      faceEnrollmentId,
    );
    if (deleteEnrollmentResult.isLeft) {
      final f = deleteEnrollmentResult.left;
      final message = f.errorMessage ?? f.toString();
      await _markDeviceSyncFailure(
        faceEnrollmentId: faceEnrollmentId,
        deviceId: deviceId,
        message: message,
      );
      emit(
        HikvisionFailure(
          'Face ID foydalanuvchisi o‘chirildi, lekin backenddagi face enrollment o‘chirilmadi: $message',
        ),
      );
      return;
    }

    _faceEnrollmentIdsByEmployeeNo.remove(_employeeKey(event.employeeNo));
    event.onSuccess.call();
    emit(const HikvisionSuccess('Foydalanuvchi o‘chirildi'));
    emit(HikvisionUserNotFound(employeeNo: event.employeeNo, name: ''));
  }
}
