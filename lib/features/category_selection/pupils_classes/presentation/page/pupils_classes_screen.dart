import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/navigation/router.dart';
import '../../../../../assets/colors/colors.dart';
import '../../../../../core/utils/context_extensions.dart';
import '../../../../common/presentation/widgets/line_widget.dart';
import '../../../main/presentation/bloc/category_selection_bloc.dart';

class PupilsClassesScreen extends StatefulWidget {
  final String organizationId;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String deviceId;

  const PupilsClassesScreen({
    super.key,
    required this.organizationId,
    required this.hikvisionBaseUrl,
    required this.hikvisionUsername,
    required this.hikvisionPassword,
    required this.deviceId,
  });

  @override
  State<PupilsClassesScreen> createState() => _PupilsClassesScreenState();
}

class _PupilsClassesScreenState extends State<PupilsClassesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<CategorySelectionBloc>().add(
      CategoryClassGroupsStarted(widget.organizationId),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<CategorySelectionBloc>();
    final current = bloc.state.classGroups;
    if (current is! CategoryClassGroupsContent) return;
    if (!current.hasMore || current.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      bloc.add(const CategoryClassGroupsLoadMore());
    }
  }

  void _openPupils(String classId) {
    context.push(
      AppRoutes.pupils,
      extra: {
        'classId': classId,
        'organizationId': widget.organizationId,
        'hikvisionBaseUrl': widget.hikvisionBaseUrl,
        'hikvisionUsername': widget.hikvisionUsername,
        'hikvisionPassword': widget.hikvisionPassword,
        'deviceId': widget.deviceId,
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
              "Tarbiyalanivchi sinflari",
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
            child: _ClassGroupsBody(
              state: state.classGroups,
              scrollController: _scrollController,
              onTap: _openPupils,
            ),
          ),
        );
      },
    );
  }
}

class _ClassGroupsBody extends StatelessWidget {
  final CategoryClassGroupsState state;
  final ScrollController scrollController;
  final void Function(String classId) onTap;

  const _ClassGroupsBody({
    required this.state,
    required this.scrollController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state is CategoryClassGroupsLoading) {
      return Center(
        child: SizedBox(
          width: 20.sp,
          height: 20.sp,
          child: CircularProgressIndicator(color: cBlack, strokeWidth: 2.sp),
        ),
      );
    }

    if (state is CategoryClassGroupsMessage) {
      final message = (state as CategoryClassGroupsMessage).content;
      return Center(
        child: Text(
          message.isEmpty ? 'Guruhlarni yuklab bo‘lmadi' : message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium!.copyWith(
            color: cBlack,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    final data = state as CategoryClassGroupsContent;
    if (data.items.isEmpty) {
      return Center(
        child: Text(
          'Guruhlar topilmadi',
          style: context.textTheme.bodyMedium!.copyWith(
            color: cBlack,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 12.h),
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

        final classGroup = data.items[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: LineWidget(
            backgroundColor: cGrey.withValues(alpha: 0.12),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            lead: Text(
              '${index + 1}',
              style: context.textTheme.bodyMedium!.copyWith(
                color: cBlack,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classGroup.name.isNotEmpty ? classGroup.name : 'Nomsiz',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cBlack,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _InfoChip(
                      label: classGroup.section.isEmpty
                          ? 'Section: -'
                          : 'Section: ${classGroup.section}',
                      color: cBlue,
                    ),
                    _InfoChip(
                      label: 'Bola soni: ${classGroup.studentCount}',
                      color: cGreen,
                    ),
                    if (classGroup.shiftName.isNotEmpty)
                      _InfoChip(label: classGroup.shiftName, color: cOrange),
                  ],
                ),
              ],
            ),
            trail: Icon(Icons.chevron_right, color: cGrey, size: 22.sp),
            onTap: () => onTap(classGroup.id),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          label,
          style: context.textTheme.bodyMedium!.copyWith(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
