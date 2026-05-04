import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../common/presentation/widgets/line_widget.dart';
import '../bloc/organization_bloc.dart';
import '../bloc/organization_state.dart';
import '../widgets/organization_app_bar.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  /*late final ScrollController _scrollController;*/

  @override
  void initState() {
    super.initState();
    /*_scrollController = ScrollController()..addListener(_onScroll);*/
    context.read<OrganizationBloc>().add(const GetOrganizationsEvent());
  }

  @override
  void dispose() {
    /*_scrollController.removeListener(_onScroll);
    _scrollController.dispose();*/
    super.dispose();
  }

  /*  void _onScroll() {
    final bloc = context.read<OrganizationBloc>();
    final state = bloc.state.organizationData;
    if (state is! OrganizationsDataContent) return;
    if (state.isLoadingMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      bloc.add(const LoadMoreOrganizationsEvent());
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationBloc, OrganizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: organizationAppBar(context, () {
            context.push(AppRoutes.account, extra: state.userMe);
          }),
          /*appBar: AppBar(
            title: Text(
              "Organizatsiyalar",
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 16.sp,
              ),
            ),
            centerTitle: true,
          ),*/
          backgroundColor: cWhite,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Builder(
              builder: (context) {
                final data = state.organizationData;

                if (data is OrganizationsDataContent) {
                  return ListView.builder(
                    /*controller: _scrollController,*/
                    itemCount: data.organizations.length,
                    itemBuilder: (_, i) {
                      /*if (i >= data.organizations.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Center(
                            child: SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: CircularProgressIndicator.adaptive(strokeWidth: 2.sp),
                            ),
                          ),
                        );
                      }*/
                      final org = data.organizations[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: LineWidget(
                          backgroundColor: cGrey,
                          isEnabled: true,
                          body: Text(
                            org.name,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: cWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            context.push(AppRoutes.devices, extra: {'organizationId': org.id, 'organizationName': org.name});
                          },
                        ),
                      );
                    },
                  );
                } else if (data is OrganizationsDataLoading) {
                  return Center(
                    child: SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(color: cBlack, strokeWidth: 2),
                    ),
                  );
                } else if (data is OrganizationsDataMessageContent) {
                  return Center(child: Text(data.content));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
