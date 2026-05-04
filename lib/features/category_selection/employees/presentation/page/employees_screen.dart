import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/navigation/router.dart';
import '../../../../../assets/colors/colors.dart';
import '../../../../../core/utils/context_extensions.dart';
import '../../../../common/presentation/widgets/common_text_field.dart';
import '../../../../common/presentation/widgets/line_widget.dart';
import '../../../main/data/data/category_position.dart';
import '../../../main/presentation/bloc/category_selection_bloc.dart';

class EmployeesScreen extends StatefulWidget {
  final String organizationId;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String deviceId;

  const EmployeesScreen({
    super.key,
    required this.organizationId,
    required this.hikvisionBaseUrl,
    required this.hikvisionUsername,
    required this.hikvisionPassword,
    required this.deviceId,
  });

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<CategorySelectionBloc>().add(
      CategoryEmployeesStarted(widget.organizationId),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<CategorySelectionBloc>();
    final current = bloc.state.employees;
    if (current is! CategoryEmployeesContent) return;
    if (!current.hasMore || current.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      bloc.add(const CategoryEmployeesLoadMore());
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<CategorySelectionBloc>().add(
        CategoryEmployeesSearchChanged(value),
      );
    });
  }

  void _openHikvision(String id, String name) {
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
        'staffId': id,
        'studentId': null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategorySelectionBloc, CategorySelectionState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(
              "Ishchilar",
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 16.sp,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: cWhite,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Qidirish',
                  onChanged: _onSearchChanged,
                  trailing: Icon(Icons.search, color: cGrey, size: 22.sp),
                ),
                SizedBox(height: 8.h),
                _PositionDropdown(state: state),
                SizedBox(height: 12.h),
                Expanded(
                  child: _EmployeesBody(
                    state: state.employees,
                    scrollController: _scrollController,
                    positionNameById: {
                      for (final position in _positionsFromState(
                        state.positions,
                      ))
                        position.id: position.name,
                    },
                    onTap: _openHikvision,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<CategoryPositionItem> _positionsFromState(CategoryPositionsState state) {
  if (state is CategoryPositionsContent) {
    return state.items;
  }
  return const [];
}

class _PositionDropdown extends StatelessWidget {
  final CategorySelectionState state;

  const _PositionDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final positionsState = state.positions;
    if (positionsState is CategoryPositionsLoading) {
      return Container(
        height: 52.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: cBlack),
          borderRadius: BorderRadius.circular(48.r),
        ),
        child: SizedBox(
          width: 18.sp,
          height: 18.sp,
          child: CircularProgressIndicator(color: cBlack, strokeWidth: 2.sp),
        ),
      );
    }

    final positions = _positionsFromState(positionsState);
    return DropdownButtonFormField<String>(
      initialValue: state.selectedPosition?.id ?? '',
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: cBlack, size: 22.sp),
      decoration: InputDecoration(
        filled: true,
        fillColor: cWhite,
        focusColor: cRed,
        hoverColor: cGreen,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(48.r),
          borderSide: const BorderSide(color: cBlack),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(48.r),
          borderSide: const BorderSide(color: cBlack),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(48.r),
          borderSide: const BorderSide(color: cBlue),
        ),
      ),
      focusColor: cWhite,
      dropdownColor: cWhite,
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(
            'Barcha lavozimlar',
            style: context.textTheme.bodyMedium!.copyWith(
              color: cBlack,
              fontSize: 14.sp,
            ),
          ),
        ),
        ...positions.map(
          (position) => DropdownMenuItem(
            value: position.id,
            child: Text(
              position.name,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        CategoryPositionItem? selected;
        if (value != null && value.isNotEmpty) {
          for (final position in positions) {
            if (position.id == value) {
              selected = position;
              break;
            }
          }
        }
        context.read<CategorySelectionBloc>().add(
          CategoryEmployeesPositionChanged(selected),
        );
      },
    );
  }
}

class _EmployeesBody extends StatelessWidget {
  final CategoryEmployeesState state;
  final ScrollController scrollController;
  final Map<String, String> positionNameById;
  final void Function(String id, String name) onTap;

  const _EmployeesBody({
    required this.state,
    required this.scrollController,
    required this.positionNameById,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state is CategoryEmployeesLoading) {
      return Center(
        child: SizedBox(
          width: 20.sp,
          height: 20.sp,
          child: CircularProgressIndicator(color: cBlack, strokeWidth: 2.sp),
        ),
      );
    }

    if (state is CategoryEmployeesMessage) {
      final message = (state as CategoryEmployeesMessage).content;
      return Center(
        child: Text(
          message.isEmpty ? 'Xodimlarni yuklab bo‘lmadi' : message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium!.copyWith(
            color: cBlack,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    final data = state as CategoryEmployeesContent;
    if (data.items.isEmpty) {
      return Center(
        child: Text(
          'Xodimlar topilmadi',
          style: context.textTheme.bodyMedium!.copyWith(
            color: cBlack,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= data.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: SizedBox(
                width: 18.sp,
                height: 18.sp,
                child: CircularProgressIndicator(
                  color: cBlack,
                  strokeWidth: 2.sp,
                ),
              ),
            ),
          );
        }

        final employee = data.items[index];
        final positionName = positionNameById[employee.positionId] ?? '';
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: LineWidget(
            backgroundColor: employee.hasFaceEnrollment
                ? cGreen.withValues(alpha: 0.16)
                : cGrey.withValues(alpha: 0.12),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${index + 1}",
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cBlack,
                    fontSize: 16,
                  ),
                ),
                Text(
                  employee.fullName.isNotEmpty ? employee.fullName : 'Nomsiz',
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cBlack,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (positionName.isNotEmpty || employee.phoneNumber.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      [
                        if (positionName.isNotEmpty) positionName,
                        if (employee.phoneNumber.isNotEmpty)
                          employee.phoneNumber,
                      ].join(' · '),
                      style: context.textTheme.bodyMedium!.copyWith(
                        color: cGrey,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
              ],
            ),
            trail: Icon(Icons.chevron_right, color: cGrey, size: 22.sp),
            onTap: () => onTap(employee.id, employee.fullName),
          ),
        );
      },
    );
  }
}
