import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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

  HikvisionBloc() : super(const HikvisionInitial()) {
    on<HikvisionStarted>(_onStarted);
    on<HikvisionCreateUserPressed>(_onCreateUserPressed);
    on<HikvisionAddPhotoPressed>(_onAddPhotoPressed);
    on<HikvisionDeleteUserPressed>(_onDeleteUserPressed);
  }

  Future<void> _onStarted(HikvisionStarted event, Emitter<HikvisionState> emit) async {
    emit(const HikvisionLoading());
    final result = await _repository.getUserByEmployeeNo(event.employeeNo);
    if (result.isRight) {
      final user = result.right;
      if (user != null) {
        final faceUrlResult = await _repository.getFaceUrlByEmployeeNo(user.employeeNo);
        if (faceUrlResult.isRight) {
          final url = faceUrlResult.right;
          if (url != null && url.isNotEmpty) {
            final bytesResult = await _repository.downloadBytesWithDigest(Uri.parse(url));
            if (bytesResult.isRight) {
              emit(HikvisionUserFound(user, photoBytes: bytesResult.right));
              return;
            }
          }
        }
        emit(HikvisionUserFound(user));
      } else {
        emit(HikvisionUserNotFound(employeeNo: event.employeeNo, name: event.name));
      }
    } else {
      final failure = result.left;
      emit(HikvisionFailure(failure.errorMessage ?? failure.toString()));
    }
  }

  Future<void> _onCreateUserPressed(HikvisionCreateUserPressed event, Emitter<HikvisionState> emit) async {
    emit(const HikvisionActionInProgress());
    final result = await _repository.createUser(employeeNo: event.employeeNo, name: event.name);
    if (result.isRight) {
      emit(const HikvisionSuccess('Foydalanuvchi Hikvision ga muvaffaqiyatli qo‘shildi'));
      add(HikvisionStarted(employeeNo: event.employeeNo, name: event.name));
    } else {
      final Failure failure = result.left;
      emit(HikvisionFailure(failure.errorMessage ?? failure.toString()));
    }
  }

  Future<void> _onAddPhotoPressed(HikvisionAddPhotoPressed event, Emitter<HikvisionState> emit) async {
    emit(const HikvisionActionInProgress());

    final captureResult = await _repository.captureFaceUrl();
    if (captureResult.isLeft) {
      final f = captureResult.left;
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }

    final faceUrl = captureResult.right;
    final sid = event.studentId?.trim() ?? '';
    final stid = event.staffId?.trim() ?? '';
    final orgId = event.organizationId?.trim() ?? '';
    final devId = event.deviceId?.trim() ?? '';
    final hasOwnerId = sid.isNotEmpty || stid.isNotEmpty;
    final syncBackend = hasOwnerId && orgId.isNotEmpty && devId.isNotEmpty;

    // Vaqtinchalik capture fayli addFace dan keyin o‘chiriladi — avval yuklab olamiz.
    List<int>? faceBytesForBackend;
    if (syncBackend) {
      try {
        final uri = _resolveHikvisionFaceDownloadUri(faceUrl);
        final bytesResult = await _repository.downloadBytesWithDigest(uri);
        if (bytesResult.isLeft) {
          final f = bytesResult.left;
          emit(HikvisionFailure('Vaqtinchalik yuz rasmini yuklab bo‘lmadi: ${f.errorMessage ?? f}'));
          add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
          return;
        }
        faceBytesForBackend = bytesResult.right;
      } catch (e) {
        emit(HikvisionFailure('Yuz URL: $e'));
        add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
        return;
      }
    }

    final addResult = await _repository.addFaceByUrl(employeeNo: event.deviceEmployeeNo, faceUrl: faceUrl);
    if (addResult.isLeft) {
      final f = addResult.left;
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }

    if (syncBackend && faceBytesForBackend != null) {
      try {
        final uploadResult = await _faceEnrollment.uploadFaceImageBytes(faceBytesForBackend);
        if (uploadResult.isLeft) {
          final f = uploadResult.left;
          emit(HikvisionFailure('Qurilmaga rasm qo‘shildi, POST /api/file xatosi: ${f.errorMessage ?? f}'));
          add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
          return;
        }

        final enrollResult = await _faceEnrollment.enrollFromDevice(
          studentId: sid.isNotEmpty ? sid : null,
          staffId: stid.isNotEmpty ? stid : null,
          faceImageId: uploadResult.right,
          organizationId: orgId,
          deviceId: devId,
        );
        if (enrollResult.isLeft) {
          final f = enrollResult.left;
          emit(
            HikvisionFailure(
              'Qurilmaga rasm qo‘shildi, face-enrollment/from-device xatosi: '
              '${f.errorMessage ?? f}',
            ),
          );
          add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
          return;
        }
      } catch (e) {
        emit(HikvisionFailure('Qurilmaga rasm qo‘shildi, backend sinxron xatosi: $e'));
        add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
        return;
      }
    }

    emit(const HikvisionSuccess('Rasm muvaffaqiyatli qo‘shildi'));
    add(HikvisionStarted(employeeNo: event.lookupEmployeeNo, name: ''));
  }

  Uri _resolveHikvisionFaceDownloadUri(String faceUrl) {
    final t = faceUrl.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return Uri.parse(t);
    }
    var base = serviceLocator<HikvisionService>().baseUrl.trim();
    if (base.isEmpty) {
      throw Exception('Hikvision baseUrl bo‘sh');
    }
    if (!base.startsWith('http://') && !base.startsWith('https://')) {
      base = 'http://$base';
    }
    return Uri.parse(base).resolve(t);
  }

  Future<void> _onDeleteUserPressed(HikvisionDeleteUserPressed event, Emitter<HikvisionState> emit) async {
    emit(const HikvisionActionInProgress());

    final result = await _repository.deleteUser(event.employeeNo);
    if (result.isLeft) {
      final f = result.left;
      emit(HikvisionFailure(f.errorMessage ?? f.toString()));
      return;
    }
    event.onSuccess.call();
    emit(const HikvisionSuccess('Foydalanuvchi o‘chirildi'));
    emit(HikvisionUserNotFound(employeeNo: event.employeeNo, name: ''));
  }
}
