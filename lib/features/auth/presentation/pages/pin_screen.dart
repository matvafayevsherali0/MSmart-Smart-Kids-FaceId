import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../common/presentation/widgets/common_text_field.dart';
import '../../../common/presentation/widgets/custom_button.dart';
import '../dialog/auth_dialogs.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, required this.isSetup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _storage = serviceLocator<StorageRepository>();
  final _auth = LocalAuthentication();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _firstPin;

  bool get _isConfirmStep => widget.isSetup && _firstPin != null;

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricLogin());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricLogin() async {
    final enabled = _storage.getBool(StoreKeys.biometricEnabled);
    if (!enabled) return;
    try {
      final canUseBiometrics = await _canUseBiometrics();
      if (!canUseBiometrics) return;

      final ok = await _auth.authenticate(
        localizedReason: 'Ilovaga kirish uchun biometrik tasdiqlashdan o‘ting',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!mounted) return;
      if (ok) {
        context.go(AppRoutes.organization);
      }
    } on LocalAuthException {
      // Auto-login should not block the PIN fallback.
    }
  }

  Future<bool> _canUseBiometrics({bool showError = false}) async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();
      final canUse = supported && canCheck && availableBiometrics.isNotEmpty;

      if (!canUse && showError && mounted) {
        await context.showPopUp(
          status: PopUpStatus.warning,
          message: "Qurilmada Face ID yoki fingerprint sozlanmagan",
        );
      }

      return canUse;
    } on LocalAuthException catch (error) {
      if (showError && mounted) {
        await context.showPopUp(
          status: PopUpStatus.error,
          message: _biometricErrorMessage(error),
        );
      }
      return false;
    }
  }

  String _biometricErrorMessage(LocalAuthException error) {
    switch (error.code) {
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noCredentialsSet:
        return "Qurilma sozlamalarida Face ID yoki fingerprintni yoqing";
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return "Bu qurilmada biometrik tasdiqlash mavjud emas";
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return "Biometrik tasdiqlash vaqtincha bloklangan. Keyinroq urinib ko'ring";
      case LocalAuthExceptionCode.uiUnavailable:
        return "Biometrik oynani ochib bo'lmadi. Ilovani qayta ochib ko'ring";
      case LocalAuthExceptionCode.authInProgress:
        return "Biometrik tasdiqlash allaqachon ishga tushgan";
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
      case LocalAuthExceptionCode.userRequestedFallback:
      case LocalAuthExceptionCode.deviceError:
      case LocalAuthExceptionCode.unknownError:
        return "Biometrik tasdiqlash amalga oshmadi";
    }
  }

  Future<void> _onContinue() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      await context.showPopUp(
        status: PopUpStatus.warning,
        message: "PIN kamida 4 ta raqam bo'lishi kerak",
      );
      return;
    }

    if (widget.isSetup) {
      if (!_isConfirmStep) {
        setState(() {
          _firstPin = pin;
          _pinController.clear();
        });
        return;
      }

      if (_firstPin != pin) {
        await context.showPopUp(
          status: PopUpStatus.error,
          message: "PIN kodlar mos kelmadi",
        );
        setState(() {
          _firstPin = null;
          _pinController.clear();
        });
        return;
      }

      setState(() => _isLoading = true);
      await _storage.putString(StoreKeys.pinCode, value: pin);
      await _storage.putBool(StoreKeys.isEnter, value: true);
      final enableBiometric = await _askEnableBiometric();
      await _storage.putBool(
        StoreKeys.biometricEnabled,
        value: enableBiometric,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(AppRoutes.organization);
      return;
    }

    final savedPin = _storage.getString(StoreKeys.pinCode);
    if (savedPin == pin) {
      context.go(AppRoutes.organization);
    } else {
      await context.showPopUp(
        status: PopUpStatus.error,
        message: "PIN noto'g'ri",
      );
    }
  }

  Future<bool> _askEnableBiometric() async {
    final shouldEnable = await showEnableBiometricDialog(context);
    if (!shouldEnable) return false;

    try {
      final canUseBiometrics = await _canUseBiometrics(showError: true);
      if (!canUseBiometrics) return false;

      return await _auth.authenticate(
        localizedReason: 'Biometrik kirishni yoqish uchun tasdiqlang',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (error) {
      if (mounted) {
        await context.showPopUp(
          status: PopUpStatus.error,
          message: _biometricErrorMessage(error),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSetup
        ? (_isConfirmStep ? "PIN kodni tasdiqlang" : "PIN kod yarating")
        : "PIN kodni kiriting";

    return Scaffold(
      backgroundColor: cWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "PIN himoya",
          style: context.textTheme.bodyMedium!.copyWith(
            color: cBlack,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            CommonTextField(
              controller: _pinController,
              hintText: "****",
              keyboardType: TextInputType.number,
              obscureText: true,
              enableInteractiveSelection: false,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.length > 6) {
                  _pinController.text = value.substring(0, 6);
                  _pinController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _pinController.text.length),
                  );
                }
              },
            ),
            SizedBox(height: 16.h),
            if (_isLoading)
              SizedBox(
                width: 22.sp,
                height: 22.sp,
                child: CircularProgressIndicator(
                  color: cBlack,
                  strokeWidth: 2.sp,
                ),
              ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: CustomButton(
                onPressed: _isLoading ? null : _onContinue,
                child: Text(
                  "Davom etish",
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
