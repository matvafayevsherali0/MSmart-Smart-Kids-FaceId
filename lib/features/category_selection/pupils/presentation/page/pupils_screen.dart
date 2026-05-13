import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/navigation/router.dart';
import '../../../../../assets/colors/colors.dart';
import '../../../../../assets/constants/network_constants.dart';
import '../../../../../core/utils/context_extensions.dart';
import '../../../../common/presentation/widgets/common_text_field.dart';
import '../../../../common/presentation/widgets/line_widget.dart';
import '../../../main/presentation/bloc/category_selection_bloc.dart';

class PupilsScreen extends StatefulWidget {
  final String classId;
  final String organizationId;
  final String hikvisionBaseUrl;
  final String hikvisionUsername;
  final String hikvisionPassword;
  final String deviceId;

  const PupilsScreen({
    super.key,
    required this.classId,
    required this.organizationId,
    required this.hikvisionBaseUrl,
    required this.hikvisionUsername,
    required this.hikvisionPassword,
    required this.deviceId,
  });

  @override
  State<PupilsScreen> createState() => _PupilsScreenState();
}

class _PupilsScreenState extends State<PupilsScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<CategorySelectionBloc>().add(
      CategoryPupilsStarted(
        organizationId: widget.organizationId,
        classGroupId: widget.classId,
      ),
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
    final current = bloc.state.pupils;
    if (current is! CategoryPupilsContent) return;
    if (!current.hasMore || current.isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      bloc.add(const CategoryPupilsLoadMore());
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<CategorySelectionBloc>().add(
        CategoryPupilsSearchChanged(value),
      );
    });
  }

  Future<void> _pullRefreshPupils() async {
    final bloc = context.read<CategorySelectionBloc>();
    final done = bloc.stream.firstWhere(
      (s) =>
          s.pupils is CategoryPupilsContent ||
          s.pupils is CategoryPupilsMessage,
    );
    bloc.add(const CategoryPupilsRefresh());
    await done;
  }

  void _openHikvision(
    String id,
    String name,
    String faceEnrollmentId,
    String faceEnrollmentFileRelativeUrl,
  ) {
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
        'staffId': null,
        'faceEnrollmentId': faceEnrollmentId,
        'faceEnrollmentFileRelativeUrl': faceEnrollmentFileRelativeUrl,
        'studentId': id,
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
              "Tarbiyalanuvchilar",
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
                SizedBox(height: 12.h),
                Expanded(
                  child: RefreshIndicator(
                    color: cBlack,
                    backgroundColor: Colors.transparent,
                    onRefresh: _pullRefreshPupils,
                    child: _PupilsBody(
                      state: state.pupils,
                      scrollController: _scrollController,
                      onTap: _openHikvision,
                    ),
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

String _photoUrl(String photoId) {
  final value = photoId.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  final root = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  if (value.startsWith('/')) {
    return '${root.substring(0, root.length - 1)}$value';
  }
  if (value.startsWith('api/')) {
    return '$root$value';
  }
  return '${root}api/file/$value';
}

class _PupilsBody extends StatelessWidget {
  final CategoryPupilsState state;
  final ScrollController scrollController;
  final void Function(
    String id,
    String name,
    String faceEnrollmentId,
    String faceEnrollmentFileRelativeUrl,
  ) onTap;

  const _PupilsBody({
    required this.state,
    required this.scrollController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minScrollExtent = MediaQuery.sizeOf(context).height * 0.35;

    if (state is CategoryPupilsLoading) {
      return ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: minScrollExtent,
            child: Center(
              child: SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CircularProgressIndicator(color: cBlack, strokeWidth: 2.sp),
              ),
            ),
          ),
        ],
      );
    }

    if (state is CategoryPupilsMessage) {
      final message = (state as CategoryPupilsMessage).content;
      return ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: minScrollExtent,
            child: Center(
              child: Text(
                message.isEmpty ? 'Tarbiyalanuvchilarni yuklab bo‘lmadi' : message,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium!.copyWith(
                  color: cBlack,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final data = state as CategoryPupilsContent;
    if (data.items.isEmpty) {
      return ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: minScrollExtent,
            child: Center(
              child: Text(
                'Tarbiyalanuvchilar topilmadi',
                style: context.textTheme.bodyMedium!.copyWith(
                  color: cBlack,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
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

        final pupil = data.items[index];
        final photoUrl = _photoUrl(pupil.photoId);
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: LineWidget(
            backgroundColor: pupil.hasFaceEnrollment
                ? cGreen.withValues(alpha: 0.16)
                : cGrey.withValues(alpha: 0.12),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            lead: photoUrl.isEmpty
                ? Text(
                    '${index + 1}',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: cBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      photoUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pupil.fullName.isNotEmpty ? pupil.fullName : 'Nomsiz',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: cBlack,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pupil.birthday.isNotEmpty || pupil.address.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      [
                        if (pupil.birthday.isNotEmpty) pupil.birthday,
                        if (pupil.address.isNotEmpty && pupil.address != '-')
                          pupil.address,
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
            onTap: () => onTap(
              pupil.id,
              pupil.fullName,
              pupil.faceEnrollmentId,
              pupil.faceEnrollmentFileRelativeUrl,
            ),
          ),
        );
      },
    );
  }
}
