import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../common/presentation/widgets/common_text_field.dart';
import '../../../common/presentation/widgets/custom_button.dart';
import '../bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _loginController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _loginController = TextEditingController(text: "+998");
    _passwordController = TextEditingController();
    _loginController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    context.read<SignInBloc>().add(
      IsDisableButtonSignInWithLogin(
        login: _loginController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cWhite,
          body: KeyboardDismisser(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 64.h),
                    child: Text(
                      "Kirish",
                      textScaler: TextScaler.linear(1.0),
                      style: context.textTheme.bodyLarge!.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: cBlack,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 64, bottom: 32),
                    child: CommonTextField(
                      controller: _loginController,
                      keyboardType: TextInputType.phone,
                      trailing: SizedBox(width: 24, height: 24),
                      enableInteractiveSelection: false,
                      inputFormatters: [UzPhoneFormatter()],
                    ),
                  ),
                  CommonTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    enableInteractiveSelection: false,
                    obscureText: !state.isHidePassword,
                    /*trailing: InkWell(
                      onTap: () {
                        context.read<SignInBloc>().add(HideEyeSignInEvent());
                      },
                      child: SvgPicture.asset(AppIcons.eyeOn, color: context.onPrimaryColor, width: 24, height: 24),
                    ),*/
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(bottom: 32.h, left: 16.w, right: 16.w),
            child: CustomButton(
              isLoading: state.isLoading,
              isDisabled: !state.isDisable,
              onPressed: () {
                  context.read<SignInBloc>().add(
                    SignInWithLogin(
                      login: _loginController.text.trim(),
                      password: _passwordController.text.trim(),
                      onSuccess: () {
                        context.showPopUp(
                          status: PopUpStatus.success,
                          message: "Muvaffaqiyatli kirdingiz",
                        );
                        Future.delayed(Duration(milliseconds: 1500), () {
                          if (!context.mounted) return;
                          context.pushReplacement(
                            AppRoutes.pin,
                            extra: {'isSetup': true},
                          );
                        });
                      },
                      onError: (String errorText) {
                        context.showPopUp(
                          status: PopUpStatus.error,
                          message: errorText,
                        );
                      },
                    ),
                  );
              },
              child: Text(
                "Kirish",
                style: context.textTheme.bodyMedium!.copyWith(
                  color: cWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            /*CButton(
              text: "Kirish",
              isLoading: state.isLoading,
              onTap: () {
                if (_formKey.currentState?.validate() == true) {
                  context.read<SignInBloc>().add(
                    SignInWithLogin(
                      login: _loginController.text.trim(),
                      password: _passwordController.text.trim(),
                      onSuccess: () {
                        context.showPopUp(status: PopUpStatus.success, message: "Muvaffaqiyatli kirdingiz");
                        Future.delayed(Duration(milliseconds: 1500), () {
                          if (!context.mounted) return;
                          context.pushReplacement(AppRoutes.organization);
                        });
                      },
                      onError: (String errorText) {
                        context.showPopUp(status: PopUpStatus.error, message: errorText);
                      },
                    ),
                  );
                }
              },
            ),*/
          ),
        );
      },
    );
  }
}
