import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../assets/constants/app_icons.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../common/data/data/user_me.dart';
import '../../../common/presentation/widgets/custom_button.dart';
import '../bloc/account_bloc.dart';
import '../dialog/account_dialogs.dart';

class AccountScreen extends StatefulWidget {
  final UserMe userMe;

  const AccountScreen({super.key, required this.userMe});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountBloc(),
      child: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) async {
          if (state.status == AccountActionStatus.failure && state.errorMessage != null) {
            await context.showPopUp(status: PopUpStatus.error, message: state.errorMessage);
          }
          if (state.status == AccountActionStatus.logoutSuccess && context.mounted) {
            context.go(AppRoutes.signIn);
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  "Foydalanuvchi hisobi",
                  style: context.textTheme.bodyMedium!.copyWith(color: cBlack, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                centerTitle: true,
              ),
              backgroundColor: cWhite,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      AppIcons.person,
                      width: 160,
                      height: 240,
                      color: cBlue,
                      errorBuilder: (_, _, _) => const Icon(Icons.person, size: 200, color: cBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.userMe.phone,
                      style: context.textTheme.bodyMedium!.copyWith(color: cBlack, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    CustomButton(
                      onPressed: () async {
                        final confirm = await showLogoutDialog(context);
                        if (!confirm || !context.mounted) return;
                        context.read<AccountBloc>().add(AccountLogoutRequested());
                      },
                      backgroundColor: cRed.withValues(alpha: .3),
                      child: Text(
                        "Chiqish",
                        style: context.textTheme.bodyMedium!.copyWith(color: cRed, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () async {
                        final confirm = await showDeleteAccountDialog(context);
                        if (!confirm || !context.mounted) return;
                        context.read<AccountBloc>().add(AccountDeleteLinkOpenRequested());
                      },
                      backgroundColor: cRed.withValues(alpha: .6),
                      child: Text(
                        "Hisobni o'chirish",
                        style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
