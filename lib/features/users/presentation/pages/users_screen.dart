import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../common/presentation/widgets/custom_button.dart';
import '../../../common/presentation/widgets/line_widget.dart';
import '../../../hikvision/data/service/hikvision_service.dart';
import '../bloc/users_bloc.dart';

class UsersScreen extends StatefulWidget {
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String organizationId;
  final String deviceId;

  const UsersScreen({
    super.key,
    this.hikvisionBaseUrl = "",
    this.hikvisionUsername = "",
    this.hikvisionPassword = "",
    this.organizationId = "",
    this.deviceId = "",
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final PageController _pageController;
  late final ScrollController _staffScrollController;
  late final ScrollController _employeeScrollController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _staffScrollController = ScrollController()..addListener(_onStaffScroll);
    _employeeScrollController = ScrollController()..addListener(_onEmployeeScroll);

    if (widget.hikvisionBaseUrl.isNotEmpty) {
      serviceLocator<HikvisionService>().updateConnection(
        baseUrl: widget.hikvisionBaseUrl,
        username: widget.hikvisionUsername,
        password: widget.hikvisionPassword,
      );
    }
    context.read<UsersBloc>().add(UsersListsStarted(widget.organizationId));
  }

  @override
  void dispose() {
    _staffScrollController.removeListener(_onStaffScroll);
    _employeeScrollController.removeListener(_onEmployeeScroll);
    _staffScrollController.dispose();
    _employeeScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onStaffScroll() {
    if (_pageIndex != 0) return;
    final bloc = context.read<UsersBloc>();
    final staff = bloc.state.staffList;
    if (staff is! StaffListContent) return;
    if (staff.isLoadingMore || !staff.hasMore) return;
    if (_staffScrollController.position.pixels >= _staffScrollController.position.maxScrollExtent - 100) {
      bloc.add(const LoadMoreStaffEvent());
    }
  }

  void _onEmployeeScroll() {
    if (_pageIndex != 1) return;
    final bloc = context.read<UsersBloc>();
    final emp = bloc.state.employeeList;
    if (emp is! EmployeeListContent) return;
    if (emp.isLoadingMore || !emp.hasMore) return;
    if (_employeeScrollController.position.pixels >= _employeeScrollController.position.maxScrollExtent - 100) {
      bloc.add(const LoadMoreEmployeesEvent());
    }
  }

  void _openHikvision({required String id, required String name, required String? staffId, required String? studentId}) {
    context.push(
      AppRoutes.hikvision,
      extra: {
        'employeeNo': id,
        'name': name,
        'hikvisionBaseUrl': widget.hikvisionBaseUrl,
        'hikvisionUsername': widget.hikvisionUsername,
        'hikvisionPassword': widget.hikvisionPassword,
        'organizationId': widget.organizationId,
        'deviceId': widget.deviceId,
        'studentId': studentId,
        'staffId': staffId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
            title: Text(
              'Staff va xodimlar',
              style: context.textTheme.bodyMedium!.copyWith(color: cBlack, fontSize: 16.sp),
            ),
            centerTitle: true,
          ),
          backgroundColor: cWhite,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _PageTabChip(
                        label: 'Staff',
                        selected: _pageIndex == 0,
                        onTap: () {
                          _pageController.animateToPage(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _PageTabChip(
                        label: 'Employee',
                        selected: _pageIndex == 1,
                        onTap: () {
                          _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _StaffListBody(
                        state: state.staffList,
                        scrollController: _staffScrollController,
                        onItemTap: _openHikvision,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _EmployeeListBody(
                        state: state.employeeList,
                        scrollController: _employeeScrollController,
                        onItemTap: _openHikvision,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
            child: CustomButton(
              onPressed: () {
                context.push(
                  AppRoutes.usersComparison,
                  extra: {
                    "organizationId": widget.organizationId,
                    "hikvisionBaseUrl": widget.hikvisionBaseUrl,
                    "hikvisionUsername": widget.hikvisionUsername,
                    "hikvisionPassword": widget.hikvisionPassword,
                  },
                );
              },
              backgroundColor: cBlue,
              child: Text(
                "Ma'lumotlarni sinxromlash",
                style: context.textTheme.bodyMedium!.copyWith(color: cWhite, fontSize: 16.sp),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PageTabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PageTabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? cBlue.withValues(alpha: 0.12) : cGrey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.bodyMedium!.copyWith(
                color: selected ? cBlue : cBlack,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffListBody extends StatelessWidget {
  final StaffListState state;
  final ScrollController scrollController;
  final void Function({required String id, required String name, required String? staffId, required String? studentId}) onItemTap;

  const _StaffListBody({required this.state, required this.scrollController, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (state is StaffListLoading) {
      return Center(
        child: SizedBox(
          width: 20.sp,
          height: 20.sp,
          child: const CircularProgressIndicator(color: cBlack, strokeWidth: 2),
        ),
      );
    }
    if (state is StaffListMessage) {
      return Center(
        child: Text((state as StaffListMessage).content, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
      );
    }
    final data = state as StaffListContent;
    if (data.items.isEmpty) {
      return Center(child: Text('Staff ro‘yxati bo‘sh', style: context.textTheme.bodyMedium));
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= data.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: SizedBox(
                width: 18.sp,
                height: 18.sp,
                child: const CircularProgressIndicator(color: cBlack, strokeWidth: 2),
              ),
            ),
          );
        }
        final item = data.items[i];
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: LineWidget(
            backgroundColor: cGrey,
            isEnabled: false,
            body: Text(
              item.fullName.isNotEmpty ? item.fullName : '—',
              style: context.textTheme.bodyMedium!.copyWith(color: cBlack, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () => onItemTap(id: item.id, name: item.fullName, staffId: item.id, studentId: null),
          ),
        );
      },
    );
  }
}

class _EmployeeListBody extends StatelessWidget {
  final EmployeeListState state;
  final ScrollController scrollController;
  final void Function({required String id, required String name, required String? staffId, required String? studentId}) onItemTap;

  const _EmployeeListBody({required this.state, required this.scrollController, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (state is EmployeeListLoading) {
      return Center(
        child: SizedBox(
          width: 20.sp,
          height: 20.sp,
          child: const CircularProgressIndicator(color: cBlack, strokeWidth: 2),
        ),
      );
    }
    if (state is EmployeeListMessage) {
      return Center(
        child: Text((state as EmployeeListMessage).content, textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
      );
    }
    final data = state as EmployeeListContent;
    if (data.items.isEmpty) {
      return Center(child: Text('Employee ro‘yxati bo‘sh', style: context.textTheme.bodyMedium));
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= data.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: SizedBox(
                width: 18.sp,
                height: 18.sp,
                child: const CircularProgressIndicator(color: cBlack, strokeWidth: 2),
              ),
            ),
          );
        }
        final item = data.items[i];
        final subtitle = item.phone.isNotEmpty ? ' · ${item.phone}' : '';
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: LineWidget(
            backgroundColor: cGrey,
            isEnabled: false,
            body: Text(
              "${item.fullName.isNotEmpty ? item.fullName : '—'}$subtitle",
              style: context.textTheme.bodyMedium!.copyWith(color: cBlack, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () => onItemTap(id: item.id, name: item.fullName, studentId: item.id, staffId: null),
          ),
        );
      },
    );
  }
}
